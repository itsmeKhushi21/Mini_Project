
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.collection_schedule import CollectionSchedule
from app.models.user import User

from app.schemas.collection_schedules import (
    CollectionScheduleCreate,
    CollectionScheduleUpdate,
    CollectionScheduleResponse,
)

from app.utils.dependencies import require_roles


router = APIRouter(
    prefix="/schedules",
    tags=["Collection Schedule Management"]
)


# 1. Manager creates a collection schedule
@router.post(
    "",
    response_model=CollectionScheduleResponse,
    status_code=status.HTTP_201_CREATED
)
def create_schedule(
    schedule_data: CollectionScheduleCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("manager"))
):
    driver = db.get(User, schedule_data.driver_id)

    if not driver or driver.role != "driver" or not driver.is_active:
        raise HTTPException(
            status_code=400,
            detail="Invalid or inactive driver"
        )

    new_schedule = CollectionSchedule(
        **schedule_data.model_dump(),
        created_by=current_user.user_id
    )

    try:
        db.add(new_schedule)
        db.commit()
        db.refresh(new_schedule)
        return new_schedule

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Could not create collection schedule"
        )


# 2. Manager views all schedules
@router.get(
    "",
    response_model=list[CollectionScheduleResponse]
)
def get_all_schedules(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("manager", "admin", "citizen"))
):
    return db.query(CollectionSchedule).order_by(
        CollectionSchedule.schedule_id.desc()
    ).all()


# 3. Driver views their assigned schedules
@router.get(
    "/my",
    response_model=list[CollectionScheduleResponse]
)
def get_driver_schedules(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("driver"))
):
    return db.query(CollectionSchedule).filter(
        CollectionSchedule.driver_id == current_user.user_id
    ).order_by(
        CollectionSchedule.starts_at.asc()
    ).all()


# 4. Manager updates a schedule
@router.patch(
    "/{schedule_id}",
    response_model=CollectionScheduleResponse
)
def update_schedule(
    schedule_id: int,
    update_data: CollectionScheduleUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("manager"))
):
    schedule = db.get(CollectionSchedule, schedule_id)

    if not schedule:
        raise HTTPException(
            status_code=404,
            detail="Collection schedule not found"
        )

    # Ignore omitted and NULL fields
    changes = update_data.model_dump(
        exclude_unset=True,
        exclude_none=True
    )

    if "driver_id" in changes:
        driver = db.get(User, changes["driver_id"])

        if not driver or driver.role != "driver" or not driver.is_active:
            raise HTTPException(
                status_code=400,
                detail="Invalid or inactive driver"
            )

    if "status" in changes:
        allowed_statuses = [
            "Scheduled",
            "In Progress",
            "Completed",
            "Cancelled"
        ]

        if changes["status"] not in allowed_statuses:
            raise HTTPException(
                status_code=400,
                detail="Invalid schedule status"
            )

    for field, value in changes.items():
        setattr(schedule, field, value)

    try:
        db.commit()
        db.refresh(schedule)
        return schedule

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Could not update collection schedule"
        )
