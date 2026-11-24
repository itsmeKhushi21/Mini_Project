
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.complaint import Complaint
from app.models.user import User
from app.models.collection_task import CollectionTask
from app.schemas.complaints import ComplaintResponse
from app.utils.dependencies import require_roles


router = APIRouter(
    prefix="/citizen",
    tags=["Citizen Dashboard"]
)


@router.get("/dashboard")
def get_citizen_dashboard(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("citizen"))
):
    # Count only the logged-in citizen's complaints
    total_complaints = db.query(Complaint).filter(
        Complaint.user_id == current_user.user_id
    ).count()

    pending_complaints = db.query(Complaint).filter(
        Complaint.user_id == current_user.user_id,
        Complaint.status == "pending"
    ).count()

    in_progress_complaints = db.query(Complaint).filter(
        Complaint.user_id == current_user.user_id,
        Complaint.status == "in_progress"
    ).count()

    resolved_complaints = db.query(Complaint).filter(
        Complaint.user_id == current_user.user_id,
        Complaint.status == "resolved"
    ).count()

    # Get the five most recent complaints
    recent_complaints = db.query(Complaint).filter(
        Complaint.user_id == current_user.user_id
    ).order_by(
        Complaint.created_at.desc()
    ).limit(5).all()

    return {
        "total_complaints": total_complaints,
        "pending_complaints": pending_complaints,
        "in_progress_complaints": in_progress_complaints,
        "resolved_complaints": resolved_complaints,
        "recent_complaints": [
            ComplaintResponse.model_validate(complaint)
            for complaint in recent_complaints
        ]
    }


@router.get("/collections")
def get_my_collections(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("citizen")),
):
    rows = (
        db.query(CollectionTask, Complaint, User)
        .join(Complaint, CollectionTask.complaint_id == Complaint.complaint_id)
        .join(User, CollectionTask.worker_id == User.user_id)
        .filter(Complaint.user_id == current_user.user_id)
        .order_by(CollectionTask.task_id.desc())
        .all()
    )
    return [
        {
            "task_id": task.task_id,
            "complaint_id": complaint.complaint_id,
            "status": task.status,
            "scheduled_at": task.scheduled_at,
            "completed_at": task.completed_at,
            "completion_notes": task.completion_notes,
            "completion_photo_url": task.completion_photo_url,
            "location": complaint.location,
            "waste_type": complaint.waste_type,
            "driver": {
                "full_name": driver.full_name,
                "phone": driver.phone,
            },
        }
        for task, complaint, driver in rows
    ]
