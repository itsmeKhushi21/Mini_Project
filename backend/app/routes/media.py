import os
import uuid
from pathlib import Path

from fastapi import APIRouter, Depends, Header, HTTPException, Request, status
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.collection_task import CollectionTask
from app.models.complaint import Complaint
from app.models.media_asset import MediaAsset
from app.models.user import User
from app.utils.dependencies import get_current_user, require_roles

router = APIRouter(prefix="/media", tags=["Media"])
MAX_IMAGE_SIZE = 5 * 1024 * 1024
IMAGE_SIGNATURES = {
    "image/jpeg": (b"\xff\xd8\xff", ".jpg"),
    "image/png": (b"\x89PNG\r\n\x1a\n", ".png"),
    "image/webp": (b"RIFF", ".webp"),
}
_configured_storage_dir = os.getenv("MEDIA_STORAGE_DIR")
STORAGE_DIR = (
    Path(_configured_storage_dir).resolve()
    if _configured_storage_dir is not None
    else Path(__file__).resolve().parents[2] / "uploads"
)


def _image_type(data: bytes) -> tuple[str, str] | None:
    for content_type, (signature, extension) in IMAGE_SIGNATURES.items():
        if data.startswith(signature):
            if content_type != "image/webp" or data[8:12] == b"WEBP":
                return content_type, extension
    return None


@router.post("", status_code=status.HTTP_201_CREATED)
async def upload_image(
    request: Request,
    purpose: str = Header(alias="X-Upload-Purpose"),
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("citizen", "driver")),
):
    if purpose not in {"complaint", "driver_issue", "task_completion"}:
        raise HTTPException(status_code=400, detail="Invalid image purpose")
    if current_user.role == "citizen" and purpose != "complaint":
        raise HTTPException(status_code=403, detail="Invalid image purpose for this role")
    if current_user.role == "driver" and purpose == "complaint":
        raise HTTPException(status_code=403, detail="Invalid image purpose for this role")

    content_length = request.headers.get("content-length")
    if content_length:
        try:
            request_size = int(content_length)
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid content length")
        if request_size < 0:
            raise HTTPException(status_code=400, detail="Invalid content length")
        if request_size > MAX_IMAGE_SIZE:
            raise HTTPException(status_code=413, detail="Image exceeds the 5 MB limit")

    chunks = bytearray()
    async for chunk in request.stream():
        chunks.extend(chunk)
        if len(chunks) > MAX_IMAGE_SIZE:
            raise HTTPException(status_code=413, detail="Image exceeds the 5 MB limit")
    image = bytes(chunks)
    detected = _image_type(image)
    if detected is None:
        raise HTTPException(status_code=415, detail="Only JPEG, PNG, and WebP images are supported")

    content_type, extension = detected
    media_id = str(uuid.uuid4())
    storage_name = f"{media_id}{extension}"
    try:
        STORAGE_DIR.mkdir(parents=True, exist_ok=True)
        (STORAGE_DIR / storage_name).write_bytes(image)
    except OSError:
        raise HTTPException(status_code=500, detail="Could not store uploaded image")

    asset = MediaAsset(
        media_id=media_id,
        owner_user_id=current_user.user_id,
        purpose=purpose,
        storage_name=storage_name,
        content_type=content_type,
        file_size=len(image),
    )
    try:
        db.add(asset)
        db.commit()
    except Exception:
        db.rollback()
        try:
            (STORAGE_DIR / storage_name).unlink(missing_ok=True)
        except OSError:
            pass
        raise HTTPException(status_code=500, detail="Could not save uploaded image metadata")

    return {"media_id": media_id, "url": f"/media/{media_id}", "content_type": content_type}


@router.get("/{media_id}")
def get_image(
    media_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    asset = db.get(MediaAsset, media_id)
    if not asset:
        raise HTTPException(status_code=404, detail="Image not found")
    can_access = (
        asset.owner_user_id == current_user.user_id
        or current_user.role == "admin"
        or (current_user.role == "manager" and asset.purpose != "complaint")
    )
    if (
        not can_access
        and asset.purpose == "complaint"
        and current_user.role == "manager"
    ):
        complaint = db.query(Complaint).filter(
            Complaint.photo_url == f"/media/{asset.media_id}"
        ).first()
        can_access = complaint is not None and (
            complaint.assigned_manager_id is None
            or complaint.assigned_manager_id == current_user.user_id
        )
    if (
        not can_access
        and asset.purpose == "complaint"
        and current_user.role == "driver"
    ):
        complaint = db.query(Complaint).filter(
            Complaint.photo_url == f"/media/{asset.media_id}"
        ).first()
        can_access = (
            complaint is not None
            and db.query(CollectionTask)
            .filter(
                CollectionTask.complaint_id == complaint.complaint_id,
                CollectionTask.worker_id == current_user.user_id,
            )
            .first()
            is not None
        )
    if not can_access and current_user.role == "citizen":
        can_access = (
            asset.purpose == "task_completion"
            and db.query(CollectionTask)
            .join(Complaint, CollectionTask.complaint_id == Complaint.complaint_id)
            .filter(
                CollectionTask.completion_photo_url == f"/media/{asset.media_id}",
                Complaint.user_id == current_user.user_id,
            )
            .first()
            is not None
        )
    if not can_access:
        raise HTTPException(status_code=403, detail="You cannot access this image")

    path = STORAGE_DIR / asset.storage_name
    if not path.is_file():
        raise HTTPException(status_code=404, detail="Image file is unavailable")
    return FileResponse(path, media_type=asset.content_type)
