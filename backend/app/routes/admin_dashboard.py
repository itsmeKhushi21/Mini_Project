
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.user import User
from app.models.complaint import Complaint
from app.models.garbage_bin import GarbageBin
from app.models.collection_task import CollectionTask

from app.utils.dependencies import require_roles


router = APIRouter(
    prefix="/admin",
    tags=["Admin Dashboard"]
)


@router.get("/dashboard")
def get_admin_dashboard(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("admin"))
):
    total_users = db.query(User).count()

    total_citizens = db.query(User).filter(
        User.role == "citizen"
    ).count()

    total_managers = db.query(User).filter(
        User.role == "manager"
    ).count()

    total_drivers = db.query(User).filter(
        User.role == "driver"
    ).count()

    total_complaints = db.query(Complaint).count()

    total_bins = db.query(GarbageBin).count()

    total_collection_tasks = db.query(CollectionTask).count()
    completed_collection_tasks = db.query(CollectionTask).filter(
        CollectionTask.status == "completed"
    ).count()
    pending_collection_tasks = db.query(CollectionTask).filter(
        CollectionTask.status.in_(["assigned", "in_progress"])
    ).count()

    return {
        "total_users": total_users,
        "total_citizens": total_citizens,
        "total_managers": total_managers,
        "total_drivers": total_drivers,
        "total_complaints": total_complaints,
        "total_bins": total_bins,
        "total_collection_tasks": total_collection_tasks,
        "completed_collection_tasks": completed_collection_tasks,
        "pending_collection_tasks": pending_collection_tasks
    }
