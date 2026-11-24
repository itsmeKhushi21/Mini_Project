
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.user import User
from app.models.complaint import Complaint
from app.models.garbage_bin import GarbageBin
from app.models.collection_task import CollectionTask

from app.utils.dependencies import require_roles


router = APIRouter(
    prefix="/dashboard",
    tags=["Dashboard Statistics"]
)


# Manager views overall dashboard statistics
@router.get("/stats")
def get_dashboard_stats(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("manager"))
):
    scope = Complaint.assigned_manager_id == current_user.user_id
    total_complaints = db.query(Complaint).filter(scope).count()

    pending_complaints = db.query(Complaint).filter(
        Complaint.status == "pending"
    ).filter(scope).count()

    in_progress_complaints = db.query(Complaint).filter(
        Complaint.status == "in_progress"
    ).filter(scope).count()

    resolved_complaints = db.query(Complaint).filter(
        Complaint.status == "resolved"
    ).filter(scope).count()

    total_bins = db.query(GarbageBin).count()

    bins_requiring_collection = db.query(GarbageBin).filter(
        GarbageBin.requires_collection == True
    ).count()

    total_drivers = db.query(User).filter(
        User.role == "driver",
        User.is_active == True
    ).count()

    total_tasks = db.query(CollectionTask).count()

    return {
        "total_complaints": total_complaints,
        "pending_complaints": pending_complaints,
        "in_progress_complaints": in_progress_complaints,
        "resolved_complaints": resolved_complaints,
        "total_bins": total_bins,
        "bins_requiring_collection": bins_requiring_collection,
        "total_drivers": total_drivers,
        "total_collection_tasks": total_tasks
    }
