
import logging

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import select

from app.database import get_db
from app.models.complaint import Complaint
from app.models.user import User
from app.models.notification import Notification
from app.models.complaint_status_history import ComplaintStatusHistory
from app.models.media_asset import MediaAsset

from app.schemas.complaints import ComplaintCreate, ComplaintResponse
from app.schemas.complaint_status import ComplaintStatusUpdate
from app.schemas.complaint_assignment import ComplaintAssignment

from app.utils.dependencies import require_roles


router = APIRouter(prefix="/complaints", tags=["Complaint Management"])
logger = logging.getLogger(__name__)


# Citizen submits a complaint
@router.post(
    "",
    response_model=ComplaintResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_complaint(
    data: ComplaintCreate,
    db: Session = Depends(get_db),
    citizen: User = Depends(require_roles("citizen")),
):
    if data.photo_url:
        media_id = data.photo_url.rsplit("/", 1)[-1]
        asset = db.get(MediaAsset, media_id)
        if (
            not asset
            or asset.owner_user_id != citizen.user_id
            or asset.purpose != "complaint"
        ):
            raise HTTPException(
                status_code=400,
                detail="Invalid complaint image reference",
            )

    complaint = Complaint(
        user_id=citizen.user_id,
        description=data.description,
        location=data.location,
        waste_type=data.waste_type,
        priority=data.priority,
        notes=data.notes,
        photo_url=data.photo_url,
        latitude=data.latitude,
        longitude=data.longitude,
    )

    try:
        db.add(complaint)
        db.flush()

        notification = Notification(
            user_id=citizen.user_id,
            title="Complaint Submitted",
            message=(
                f"Your complaint #{complaint.complaint_id} "
                "has been submitted successfully."
            ),
            notification_type="complaint",
        )

        db.add(notification)
        db.commit()
        db.refresh(complaint)

        return complaint

    except Exception:
        db.rollback()
        logger.exception(
            "Could not submit complaint for citizen user_id=%s",
            citizen.user_id,
        )
        raise HTTPException(
            status_code=500,
            detail=(
                "The complaint could not be saved to the database. "
                "Please try again; contact support if the issue persists."
            ),
        )


# Citizen views their own complaints
@router.get(
    "/my",
    response_model=list[ComplaintResponse],
)
def get_my_complaints(
    db: Session = Depends(get_db),
    citizen: User = Depends(require_roles("citizen")),
):
    complaints = db.scalars(
        select(Complaint)
        .where(Complaint.user_id == citizen.user_id)
        .order_by(Complaint.created_at.desc())
    ).all()

    return complaints


# Manager views all complaints
@router.get(
    "",
    response_model=list[ComplaintResponse],
)
def get_all_complaints(
    db: Session = Depends(get_db),
    manager: User = Depends(require_roles("manager", "admin")),
):
    query = select(Complaint)
    if manager.role == "manager":
        query = query.where(
            (Complaint.assigned_manager_id == manager.user_id)
            | Complaint.assigned_manager_id.is_(None)
        )
    complaints = db.scalars(query.order_by(Complaint.created_at.desc())).all()

    return complaints


# Manager updates complaint status and records history
@router.patch(
    "/{complaint_id}/status",
    response_model=ComplaintResponse,
)
def update_complaint_status(
    complaint_id: int,
    data: ComplaintStatusUpdate,
    db: Session = Depends(get_db),
    manager: User = Depends(require_roles("manager", "admin")),
):
    complaint = db.get(Complaint, complaint_id)

    if not complaint:
        raise HTTPException(
            status_code=404,
            detail="Complaint not found",
        )

    old_status = complaint.status

    # Avoid unnecessary history entries and notifications
    if old_status == data.status:
        return complaint

    complaint.status = data.status

    if data.notes is not None:
        complaint.notes = data.notes

    history = ComplaintStatusHistory(
        complaint_id=complaint.complaint_id,
        old_status=old_status,
        new_status=complaint.status,
        changed_by=manager.user_id,
        remarks=data.notes,
    )

    notification = Notification(
        user_id=complaint.user_id,
        title="Complaint Status Updated",
        message=(
            f"Your complaint #{complaint.complaint_id} "
            f"status has been changed from {old_status} "
            f"to {complaint.status}."
        ),
        notification_type="complaint_update",
    )

    try:
        db.add(history)
        db.add(notification)
        db.commit()
        db.refresh(complaint)

        return complaint

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Could not update complaint status",
        )


# Manager assigns complaint to another Manager
@router.patch(
    "/{complaint_id}/assign",
    response_model=ComplaintResponse,
)
def assign_complaint(
    complaint_id: int,
    data: ComplaintAssignment,
    db: Session = Depends(get_db),
    current_manager: User = Depends(require_roles("manager")),
):
    complaint = db.get(Complaint, complaint_id)

    if not complaint:
        raise HTTPException(
            status_code=404,
            detail="Complaint not found",
        )

    assigned_manager = db.get(User, data.assigned_manager_id)

    if (
        not assigned_manager
        or assigned_manager.role != "manager"
        or not assigned_manager.is_active
    ):
        raise HTTPException(
            status_code=400,
            detail="Invalid Manager ID",
        )

    # Avoid duplicate assignment notifications
    if complaint.assigned_manager_id == assigned_manager.user_id:
        return complaint

    complaint.assigned_manager_id = assigned_manager.user_id

    notification = Notification(
        user_id=assigned_manager.user_id,
        title="New Complaint Assigned",
        message=(
            f"Complaint #{complaint.complaint_id} "
            "has been assigned to you."
        ),
        notification_type="complaint_assignment",
    )

    try:
        db.add(notification)
        db.commit()
        db.refresh(complaint)

        return complaint

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Could not assign complaint",
        )


# Manager views complaints assigned to them
@router.get(
    "/assigned",
    response_model=list[ComplaintResponse],
)
def get_assigned_complaints(
    db: Session = Depends(get_db),
    manager: User = Depends(require_roles("manager")),
):
    complaints = db.scalars(
        select(Complaint)
        .where(
            (Complaint.assigned_manager_id == manager.user_id)
            | Complaint.assigned_manager_id.is_(None)
        )
        .order_by(Complaint.created_at.desc())
    ).all()

    return complaints
