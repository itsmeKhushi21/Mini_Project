
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.bin_maintenance_log import BinMaintenanceLog
from app.models.garbage_bin import GarbageBin
from app.models.user import User

from app.schemas.bin_maintenance_logs import (
    BinMaintenanceCreate,
    BinMaintenanceUpdate,
    BinMaintenanceResponse,
)

from app.utils.dependencies import require_roles


router = APIRouter(
    prefix="/bin-maintenance-logs",
    tags=["Bin Maintenance Logs"]
)


# 1. Manager or driver reports a bin maintenance issue
@router.post(
    "",
    response_model=BinMaintenanceResponse,
    status_code=status.HTTP_201_CREATED
)
def create_maintenance_report(
    data: BinMaintenanceCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("manager", "driver"))
):
    garbage_bin = db.get(GarbageBin, data.bin_id)

    if not garbage_bin:
        raise HTTPException(
            status_code=404,
            detail="Garbage bin not found"
        )

    maintenance = BinMaintenanceLog(
        bin_id=data.bin_id,
        reported_by=current_user.user_id,
        description=data.description
    )

    try:
        db.add(maintenance)
        db.commit()
        db.refresh(maintenance)
        return maintenance

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Could not create maintenance report"
        )


# 2. Manager views all maintenance reports
@router.get(
    "",
    response_model=list[BinMaintenanceResponse]
)
def get_all_maintenance_logs(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("manager", "admin"))
):
    logs = db.query(BinMaintenanceLog).order_by(
        BinMaintenanceLog.reported_at.desc()
    ).all()

    return logs


# 3. Manager updates maintenance status
@router.patch(
    "/{maintenance_id}",
    response_model=BinMaintenanceResponse
)
def update_maintenance_status(
    maintenance_id: int,
    data: BinMaintenanceUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("manager", "admin"))
):
    maintenance = db.get(BinMaintenanceLog, maintenance_id)

    if not maintenance:
        raise HTTPException(
            status_code=404,
            detail="Maintenance report not found"
        )

    if maintenance.maintenance_status in ["Completed", "Cancelled"]:
        raise HTTPException(
            status_code=400,
            detail="This maintenance report is already closed"
        )

    maintenance.maintenance_status = data.maintenance_status

    if data.maintenance_status == "Completed":
        maintenance.completed_at = datetime.now(timezone.utc)
    else:
        maintenance.completed_at = None

    try:
        db.commit()
        db.refresh(maintenance)
        return maintenance

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Could not update maintenance status"
        )
