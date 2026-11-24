
from typing import Literal

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.user import User
from app.models.driver_profile import DriverProfile

from app.schemas.users import StaffCreateRequest, DriverCreateRequest
from app.schemas.auth import UserResponse, ProfileUpdate

from app.utils.security import hash_password
from app.utils.dependencies import require_roles


router = APIRouter(
    prefix="/users",
    tags=["User Management"]
)


class UserStatusUpdate(BaseModel):
    is_active: bool


# 1. Admin creates Manager accounts
@router.post(
    "/managers",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED
)
def create_manager(
    data: StaffCreateRequest,
    db: Session = Depends(get_db),
    admin: User = Depends(require_roles("admin"))
):
    existing_user = db.scalar(
        select(User).where(User.email == data.email)
    )

    if existing_user:
        raise HTTPException(
            status_code=409,
            detail="Email is already registered"
        )

    manager = User(
        full_name=data.full_name.strip(),
        email=data.email,
        password_hash=hash_password(data.password),
        role="manager",
        phone=data.phone,
        is_active=True,
        created_by_user_id=admin.user_id
    )

    db.add(manager)

    try:
        db.commit()
        db.refresh(manager)
        return manager

    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="Could not create manager. Check duplicate details."
        )


# 2. Manager creates Driver accounts and Driver Profiles
@router.post(
    "/drivers",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED
)
def create_driver(
    data: DriverCreateRequest,
    db: Session = Depends(get_db),
    manager: User = Depends(require_roles("manager"))
):
    existing_user = db.scalar(
        select(User).where(User.email == data.email)
    )

    if existing_user:
        raise HTTPException(
            status_code=409,
            detail="Email is already registered"
        )

    employee_id = (
        data.employee_id.strip()
        if data.employee_id and data.employee_id.strip()
        else None
    )

    if employee_id:
        existing_employee = db.scalar(
            select(DriverProfile).where(
                DriverProfile.employee_id == employee_id
            )
        )

        if existing_employee:
            raise HTTPException(
                status_code=409,
                detail="Employee ID is already registered"
            )

    try:
        driver = User(
            full_name=data.full_name.strip(),
            email=data.email,
            password_hash=hash_password(data.password),
            role="driver",
            phone=data.phone,
            is_active=True,
            created_by_user_id=manager.user_id
        )

        db.add(driver)
        db.flush()

        driver_profile = DriverProfile(
            user_id=driver.user_id,
            employee_id=employee_id,
            vehicle_registration=(
                data.vehicle_registration.strip()
                if data.vehicle_registration
                and data.vehicle_registration.strip()
                else None
            )
        )

        db.add(driver_profile)
        db.commit()
        db.refresh(driver)

        return driver

    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="Driver account or profile information already exists."
        )

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Could not create driver account."
        )


# 3. Admin views all users or filters users by role
@router.get(
    "",
    response_model=list[UserResponse]
)
def get_all_users(
    role: Literal["admin", "manager", "driver", "citizen"] | None = None,
    db: Session = Depends(get_db),
    admin: User = Depends(require_roles("admin"))
):
    query = select(User)

    if role is not None:
        query = query.where(User.role == role)

    users = db.scalars(
        query.order_by(User.user_id.desc())
    ).all()

    return users


# 4. Admin views an individual user
@router.get(
    "/{user_id}",
    response_model=UserResponse
)
def get_user(
    user_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(require_roles("admin"))
):
    user = db.get(User, user_id)

    if not user:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    return user


# 5. Admin activates or deactivates a user
@router.patch(
    "/{user_id}/status",
    response_model=UserResponse
)
def update_user_status(
    user_id: int,
    data: UserStatusUpdate,
    db: Session = Depends(get_db),
    admin: User = Depends(require_roles("admin"))
):
    user = db.get(User, user_id)

    if not user:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    if user.user_id == admin.user_id and not data.is_active:
        raise HTTPException(
            status_code=400,
            detail="You cannot deactivate your own account"
        )

    user.is_active = data.is_active

    try:
        db.commit()
        db.refresh(user)
        return user

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Could not update user status"
        )


@router.patch("/{user_id}", response_model=UserResponse)
def update_user(
    user_id: int,
    data: ProfileUpdate,
    db: Session = Depends(get_db),
    admin: User = Depends(require_roles("admin")),
):
    user = db.get(User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    changes = data.model_dump(exclude_unset=True)
    if "email" in changes:
        duplicate = db.scalar(
            select(User).where(User.email == changes["email"], User.user_id != user_id)
        )
        if duplicate:
            raise HTTPException(status_code=409, detail="Email is already registered")
    for field, value in changes.items():
        setattr(user, field, value.strip() if isinstance(value, str) else value)
    try:
        db.commit()
        db.refresh(user)
        return user
    except Exception:
        db.rollback()
        raise HTTPException(status_code=500, detail="Could not update user")
