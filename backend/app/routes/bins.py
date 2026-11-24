
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.garbage_bin import GarbageBin
from app.models.bin_collection_log import BinCollectionLog
from app.models.bin_maintenance_log import BinMaintenanceLog
from app.models.user import User

from app.schemas.garbage_bins import (
    GarbageBinCreate,
    GarbageBinUpdate,
    GarbageBinResponse,
)

from app.utils.dependencies import require_roles


router = APIRouter(
    prefix="/bins",
    tags=["Garbage Bin Management"]
)


# 1. Manager adds a garbage bin
@router.post(
    "",
    response_model=GarbageBinResponse,
    status_code=status.HTTP_201_CREATED
)
def create_bin(
    bin_data: GarbageBinCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("manager", "admin"))
):
    existing_bin = db.query(GarbageBin).filter(
        GarbageBin.bin_code == bin_data.bin_code
    ).first()

    if existing_bin:
        raise HTTPException(
            status_code=400,
            detail="Bin code already exists"
        )

    new_bin = GarbageBin(**bin_data.model_dump())

    try:
        db.add(new_bin)
        db.commit()
        db.refresh(new_bin)
        return new_bin

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Could not create garbage bin"
        )


# 2. Manager views all garbage bins
@router.get(
    "",
    response_model=list[GarbageBinResponse]
)
def get_all_bins(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("manager", "admin", "citizen"))
):
    return db.query(GarbageBin).order_by(
        GarbageBin.bin_id.desc()
    ).all()


# 3. Manager views one garbage bin
@router.get(
    "/{bin_id}",
    response_model=GarbageBinResponse
)
def get_bin(
    bin_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("manager", "admin", "citizen"))
):
    garbage_bin = db.get(GarbageBin, bin_id)

    if not garbage_bin:
        raise HTTPException(
            status_code=404,
            detail="Garbage bin not found"
        )

    return garbage_bin


# 4. Manager updates a garbage bin
@router.patch(
    "/{bin_id}",
    response_model=GarbageBinResponse
)
def update_bin(
    bin_id: int,
    bin_data: GarbageBinUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("manager", "admin"))
):
    garbage_bin = db.get(GarbageBin, bin_id)

    if not garbage_bin:
        raise HTTPException(
            status_code=404,
            detail="Garbage bin not found"
        )

    # Ignore omitted and NULL fields
    update_data = bin_data.model_dump(
        exclude_unset=True,
        exclude_none=True
    )

    for field, value in update_data.items():
        setattr(garbage_bin, field, value)

    try:
        db.commit()
        db.refresh(garbage_bin)
        return garbage_bin

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Could not update garbage bin"
        )


# 5. Manager deletes a garbage bin
@router.delete("/{bin_id}")
def delete_bin(
    bin_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("manager", "admin"))
):
    garbage_bin = db.get(GarbageBin, bin_id)

    if not garbage_bin:
        raise HTTPException(
            status_code=404,
            detail="Garbage bin not found"
        )

    # Prevent deletion if collection logs exist
    has_collection_logs = db.query(BinCollectionLog).filter(
        BinCollectionLog.bin_id == bin_id
    ).first()

    # Prevent deletion if maintenance logs exist
    has_maintenance_logs = db.query(BinMaintenanceLog).filter(
        BinMaintenanceLog.bin_id == bin_id
    ).first()

    if has_collection_logs or has_maintenance_logs:
        raise HTTPException(
            status_code=400,
            detail="Cannot delete this bin because it has associated records"
        )

    try:
        db.delete(garbage_bin)
        db.commit()

        return {
            "message": "Garbage bin deleted successfully"
        }

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Could not delete garbage bin"
        )
