
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.user import User
from app.schemas.auth import (
    RegisterRequest,
    LoginRequest,
    AuthResponse,
    UserResponse,
    ProfileUpdate,
    PasswordChangeRequest,
)
from app.utils.security import (
    hash_password,
    verify_password,
    create_access_token,
)

from app.utils.dependencies import get_current_user

router = APIRouter(prefix="/auth", tags=["Authentication"])


# Citizen registration
@router.post(
    "/register",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
)
def register_user(data: RegisterRequest, db: Session = Depends(get_db)):

    existing_user = db.scalar(
        select(User).where(User.email == data.email)
    )

    if existing_user:
        raise HTTPException(
            status_code=409,
            detail="Email is already registered",
        )

    new_user = User(
        full_name=data.full_name.strip(),
        email=data.email,
        password_hash=hash_password(data.password),
        role="citizen",
        phone=data.phone,
        is_active=True,
    )

    db.add(new_user)

    try:
        db.commit()
        db.refresh(new_user)
    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Could not create user account",
        )

    return new_user


# Login for all four roles
@router.post("/login", response_model=AuthResponse)
def login_user(data: LoginRequest, db: Session = Depends(get_db)):

    user = db.scalar(
        select(User).where(User.email == data.email)
    )

    if not user or not verify_password(
        data.password, user.password_hash
    ):
        raise HTTPException(
            status_code=401,
            detail="Incorrect email or password",
        )

    if not user.is_active:
        raise HTTPException(
            status_code=403,
            detail="Your account is inactive",
        )

    access_token = create_access_token(
        {
            "sub": str(user.user_id),
            "role": user.role,
        }
    )

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": user,
    }

@router.get("/me", response_model=UserResponse)
def get_my_profile(
    current_user: User = Depends(get_current_user),
):
    return current_user


@router.patch("/me", response_model=UserResponse)
def update_my_profile(
    data: ProfileUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    changes = data.model_dump(exclude_unset=True)

    if "email" in changes:
        existing = db.scalar(
            select(User).where(
                User.email == changes["email"],
                User.user_id != current_user.user_id,
            )
        )
        if existing:
            raise HTTPException(status_code=409, detail="Email is already registered")

    for field, value in changes.items():
        if field == "phone" and value is not None:
            value = value.strip()
        elif isinstance(value, str):
            value = value.strip()
        setattr(current_user, field, value)

    try:
        db.commit()
        db.refresh(current_user)
        return current_user
    except Exception:
        db.rollback()
        raise HTTPException(status_code=500, detail="Could not update profile")


@router.patch("/password")
def change_my_password(
    data: PasswordChangeRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if not verify_password(data.current_password, current_user.password_hash):
        raise HTTPException(status_code=400, detail="Current password is incorrect")
    current_user.password_hash = hash_password(data.new_password)
    try:
        db.commit()
        return {"message": "Password changed successfully"}
    except Exception:
        db.rollback()
        raise HTTPException(status_code=500, detail="Could not change password")
