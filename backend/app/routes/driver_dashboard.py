
from datetime import datetime, timezone

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.user import User
from app.models.collection_task import CollectionTask
from app.models.collection_schedule import CollectionSchedule
from app.models.bin_collection_log import BinCollectionLog

from app.utils.dependencies import require_roles


router = APIRouter(
    prefix="/driver",
    tags=["Driver Dashboard"]
)


@router.get("/dashboard")
def get_driver_dashboard(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("driver"))
):
    # Task statistics for the logged-in driver
    driver_tasks = db.query(CollectionTask).filter(
        CollectionTask.worker_id == current_user.user_id
    )

    total_tasks = driver_tasks.count()

    assigned_tasks = db.query(CollectionTask).filter(
        CollectionTask.worker_id == current_user.user_id,
        CollectionTask.status == "assigned"
    ).count()

    in_progress_tasks = db.query(CollectionTask).filter(
        CollectionTask.worker_id == current_user.user_id,
        CollectionTask.status == "in_progress"
    ).count()

    completed_tasks = db.query(CollectionTask).filter(
        CollectionTask.worker_id == current_user.user_id,
        CollectionTask.status == "completed"
    ).count()

    # Upcoming collection schedules
    now = datetime.now(timezone.utc)

    upcoming_schedules = db.query(CollectionSchedule).filter(
        CollectionSchedule.driver_id == current_user.user_id,
        CollectionSchedule.starts_at >= now,
        CollectionSchedule.status == "Scheduled"
    ).order_by(
        CollectionSchedule.starts_at.asc()
    ).limit(5).all()

    # Recent bin collection history
    recent_collections = db.query(BinCollectionLog).filter(
        BinCollectionLog.driver_id == current_user.user_id
    ).order_by(
        BinCollectionLog.collected_at.desc()
    ).limit(5).all()

    return {
        "total_tasks": total_tasks,
        "assigned_tasks": assigned_tasks,
        "in_progress_tasks": in_progress_tasks,
        "completed_tasks": completed_tasks,
        "upcoming_schedules": [
            {
                "schedule_id": schedule.schedule_id,
                "waste_type": schedule.waste_type,
                "area": schedule.area,
                "starts_at": schedule.starts_at,
                "vehicle": schedule.vehicle,
                "status": schedule.status
            }
            for schedule in upcoming_schedules
        ],
        "recent_collections": [
            {
                "collection_log_id": log.collection_log_id,
                "bin_id": log.bin_id,
                "collected_at": log.collected_at,
                "fill_level_before": log.fill_level_before,
                "notes": log.notes
            }
            for log in recent_collections
        ]
    }
