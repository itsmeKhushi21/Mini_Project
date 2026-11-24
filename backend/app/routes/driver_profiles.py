
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.user import User
from app.models.driver_profile import DriverProfile
from app.models.collection_task import CollectionTask

from app.schemas.driver_profiles import (
    DriverProfileUpdate,
    DriverProfileResponse,
)

from app.utils.dependencies import require_roles


router = APIRouter(
    prefix="/driver-profiles",
    tags=["Driver Profiles"]
)


def _profile_response(profile: DriverProfile, full_name: str) -> dict:
    return {
        "driver_profile_id": profile.driver_profile_id,
        "user_id": profile.user_id,
        "full_name": full_name,
        "employee_id": profile.employee_id,
        "vehicle_registration": profile.vehicle_registration,
        "availability": profile.availability,
        "created_at": profile.created_at,
    }


def has_active_task(db: Session, user_id: int) -> bool:
    return db.query(CollectionTask).filter(
        CollectionTask.worker_id == user_id,
        CollectionTask.status.in_(["assigned", "in_progress"])
    ).first() is not None


# 1. Manager views all driver profiles
@router.get("/", response_model=list[DriverProfileResponse])
def get_all_driver_profiles(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("manager"))
):
    rows = db.execute(
        select(DriverProfile, User.full_name)
        .join(User, DriverProfile.user_id == User.user_id)
        .where(User.role == "driver")
        .order_by(DriverProfile.driver_profile_id.desc())
    ).all()

    return [_profile_response(profile, full_name) for profile, full_name in rows]


# 2. Driver views their own profile
@router.get("/me", response_model=DriverProfileResponse)
def get_my_driver_profile(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("driver"))
):
    profile = db.query(DriverProfile).filter(
        DriverProfile.user_id == current_user.user_id
    ).first()

    if not profile:
        raise HTTPException(
            status_code=404,
            detail="Driver profile not found"
        )

    return _profile_response(profile, current_user.full_name)


# 3. Manager views one driver profile
@router.get("/{user_id}", response_model=DriverProfileResponse)
def get_driver_profile(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("manager"))
):
    driver = db.get(User, user_id)

    if not driver or driver.role != "driver":
        raise HTTPException(
            status_code=404,
            detail="Driver not found"
        )

    profile = db.query(DriverProfile).filter(
        DriverProfile.user_id == user_id
    ).first()

    if not profile:
        raise HTTPException(
            status_code=404,
            detail="Driver profile not found"
        )

    return _profile_response(profile, driver.full_name)


@router.patch("/me", response_model=DriverProfileResponse)
def update_my_driver_profile(
    update_data: DriverProfileUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("driver")),
):
    profile = db.query(DriverProfile).filter(
        DriverProfile.user_id == current_user.user_id
    ).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Driver profile not found")

    changes = update_data.model_dump(
        exclude_unset=True,
        exclude_none=True,
    )
    if not changes:
        raise HTTPException(status_code=400, detail="No changes provided")

    if "availability" in changes:
        active_task = has_active_task(db, current_user.user_id)
        if active_task and changes["availability"] != "Busy":
            raise HTTPException(
                status_code=400,
                detail="Cannot change availability while the driver has an active task",
            )

    for field, value in changes.items():
        setattr(profile, field, value)

    try:
        db.commit()
        db.refresh(profile)
        return _profile_response(profile, current_user.full_name)
    except Exception:
        db.rollback()
        raise HTTPException(status_code=500, detail="Could not update driver profile")


# 4. Manager updates a driver profile. Keep this dynamic route after /me so
# the manager-only route cannot intercept the driver's self-service endpoint.
@router.patch("/{user_id}", response_model=DriverProfileResponse)
def update_driver_profile(
    user_id: int,
    update_data: DriverProfileUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("manager"))
):
    driver = db.get(User, user_id)

    if not driver or driver.role != "driver":
        raise HTTPException(
            status_code=404,
            detail="Driver not found"
        )

    profile = db.query(DriverProfile).filter(
        DriverProfile.user_id == user_id
    ).first()

    if not profile:
        raise HTTPException(
            status_code=404,
            detail="Driver profile not found"
        )

    changes = update_data.model_dump(
        exclude_unset=True,
        exclude_none=True
    )

    if not changes:
        raise HTTPException(
            status_code=400,
            detail="No changes provided"
        )

    if "availability" in changes:
        new_availability = changes["availability"]
        active_task = has_active_task(db, user_id)

        if active_task and new_availability != "Busy":
            raise HTTPException(
                status_code=400,
                detail="Cannot change availability while the driver has an active task"
            )

    for field, value in changes.items():
        setattr(profile, field, value)

    try:
        db.commit()
        db.refresh(profile)
        return _profile_response(profile, driver.full_name)

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Could not update driver profile"
        )
