
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.bin_collection_log import BinCollectionLog
from app.models.garbage_bin import GarbageBin
from app.models.user import User

from app.schemas.bin_collection_logs import (
    BinCollectionLogCreate,
    BinCollectionLogResponse,
)

from app.utils.dependencies import require_roles


router = APIRouter(
    prefix="/bin-collection-logs",
    tags=["Bin Collection Logs"]
)


# 1. Driver records a garbage bin collection
@router.post(
    "",
    response_model=BinCollectionLogResponse,
    status_code=status.HTTP_201_CREATED
)
def create_bin_collection_log(
    data: BinCollectionLogCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("driver"))
):
    garbage_bin = db.get(GarbageBin, data.bin_id)

    if not garbage_bin:
        raise HTTPException(
            status_code=404,
            detail="Garbage bin not found"
        )

    if data.fill_level_before is not None:
        if data.fill_level_before != garbage_bin.fill_level:
            raise HTTPException(
                status_code=400,
                detail="Fill level does not match the current bin fill level"
            )

    collected_at = datetime.now(timezone.utc)

    log = BinCollectionLog(
        bin_id=data.bin_id,
        driver_id=current_user.user_id,
        collected_at=collected_at,
        fill_level_before=garbage_bin.fill_level,
        notes=data.notes,
        photo_url=data.photo_url
    )

    # Update bin after collection
    garbage_bin.fill_level = 0
    garbage_bin.requires_collection = False
    garbage_bin.last_collection = collected_at

    try:
        db.add(log)
        db.commit()
        db.refresh(log)
        return log

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Could not record bin collection"
        )


# 2. Driver views their own collection logs
@router.get(
    "/my",
    response_model=list[BinCollectionLogResponse]
)
def get_my_collection_logs(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("driver"))
):
    logs = db.query(BinCollectionLog).filter(
        BinCollectionLog.driver_id == current_user.user_id
    ).order_by(
        BinCollectionLog.collected_at.desc()
    ).all()

    return logs


# 3. Manager views all bin collection logs
@router.get(
    "",
    response_model=list[BinCollectionLogResponse]
)
def get_all_collection_logs(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("manager", "admin"))
):
    logs = db.query(BinCollectionLog).order_by(
        BinCollectionLog.collected_at.desc()
    ).all()

    return logs
