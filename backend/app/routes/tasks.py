
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db

from app.models.collection_task import CollectionTask
from app.models.complaint import Complaint
from app.models.complaint_status_history import ComplaintStatusHistory
from app.models.notification import Notification
from app.models.user import User
from app.models.driver_profile import DriverProfile
from app.models.media_asset import MediaAsset

from app.schemas.collection_tasks import (
    CollectionTaskCreate,
    CollectionTaskStatusUpdate,
    CollectionTaskResponse,
    DriverAssignedTaskResponse,
)

from app.utils.dependencies import require_roles


router = APIRouter(
    prefix="/tasks",
    tags=["Collection Tasks"]
)


def has_active_task(db: Session, user_id: int) -> bool:
    return db.query(CollectionTask).filter(
        CollectionTask.worker_id == user_id,
        CollectionTask.status.in_(["assigned", "in_progress"])
    ).first() is not None


# 1. Manager assigns a complaint to a driver
@router.post(
    "",
    response_model=CollectionTaskResponse,
    status_code=status.HTTP_201_CREATED
)
def create_collection_task(
    task_data: CollectionTaskCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("manager"))
):
    complaint = db.get(Complaint, task_data.complaint_id)

    if not complaint:
        raise HTTPException(
            status_code=404,
            detail="Complaint not found"
        )

    if complaint.status == "resolved":
        raise HTTPException(
            status_code=400,
            detail="Cannot assign a task to a resolved complaint"
        )

    if complaint.assigned_manager_id is None:
        complaint.assigned_manager_id = current_user.user_id
    elif complaint.assigned_manager_id != current_user.user_id:
        raise HTTPException(
            status_code=403,
            detail="You can only assign tasks to complaints assigned to you"
        )

    driver = db.get(User, task_data.worker_id)

    if not driver or driver.role != "driver":
        raise HTTPException(
            status_code=400,
            detail="Invalid driver ID"
        )

    if not driver.is_active:
        raise HTTPException(
            status_code=400,
            detail="Driver account is inactive"
        )

    driver_profile = db.query(DriverProfile).filter(
        DriverProfile.user_id == driver.user_id
    ).first()

    if not driver_profile:
        raise HTTPException(
            status_code=404,
            detail="Driver profile not found"
        )

    if driver_profile.availability != "Available":
        raise HTTPException(
            status_code=400,
            detail=f"Driver is currently {driver_profile.availability}"
        )

    existing_task = db.query(CollectionTask).filter(
        CollectionTask.complaint_id == task_data.complaint_id,
        CollectionTask.status.in_(["assigned", "in_progress"])
    ).first()

    if existing_task:
        raise HTTPException(
            status_code=400,
            detail="An active collection task already exists for this complaint"
        )

    new_task = CollectionTask(
        complaint_id=task_data.complaint_id,
        worker_id=task_data.worker_id,
        scheduled_at=task_data.scheduled_at,
        assigned_by=current_user.user_id
    )

    try:
        db.add(new_task)
        db.flush()

        driver_profile.availability = "Busy"
        previous_status = complaint.status
        complaint.status = "assigned"
        if previous_status != complaint.status:
            db.add(ComplaintStatusHistory(
                complaint_id=complaint.complaint_id,
                old_status=previous_status,
                new_status=complaint.status,
                changed_by=current_user.user_id,
                remarks="Collection task assigned",
            ))
            db.add(Notification(
                user_id=complaint.user_id,
                title="Driver assigned",
                message=f"A driver has been assigned to complaint #{complaint.complaint_id}.",
                notification_type="complaint_update",
            ))

        notification = Notification(
            user_id=driver.user_id,
            title="New Collection Task",
            message=f"You have been assigned collection task #{new_task.task_id}.",
            notification_type="task_assignment"
        )

        db.add(notification)

        db.commit()
        db.refresh(new_task)

        return new_task

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Could not create collection task"
        )


# 2. Driver views assigned tasks with complaint and customer details
@router.get(
    "/assigned",
    response_model=list[DriverAssignedTaskResponse]
)
def get_driver_tasks(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("driver"))
):
    results = (
        db.query(CollectionTask, Complaint, User)
        .join(
            Complaint,
            CollectionTask.complaint_id == Complaint.complaint_id
        )
        .join(
            User,
            Complaint.user_id == User.user_id
        )
        .filter(
            CollectionTask.worker_id == current_user.user_id
        )
        .order_by(
            CollectionTask.task_id.desc()
        )
        .all()
    )

    return [
        {
            "task_id": task.task_id,
            "complaint_id": task.complaint_id,
            "worker_id": task.worker_id,
            "scheduled_at": task.scheduled_at,
            "status": task.status,
            "completed_at": task.completed_at,
            "completion_notes": task.completion_notes,
            "completion_photo_url": task.completion_photo_url,
            "complaint": {
                "description": complaint.description,
                "location": complaint.location,
                "waste_type": complaint.waste_type,
                "priority": complaint.priority,
                "latitude": complaint.latitude,
                "longitude": complaint.longitude,
                "photo_url": complaint.photo_url,
            },
            "customer": {
                "full_name": customer.full_name,
                "phone": customer.phone,
            },
        }
        for task, complaint, customer in results
    ]


# 3. Manager views all collection tasks
@router.get(
    "",
    response_model=list[CollectionTaskResponse]
)
def get_all_tasks(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("manager", "admin"))
):
    return db.query(CollectionTask).order_by(
        CollectionTask.task_id.desc()
    ).all()


# 4. Driver updates task status and complaint history
@router.patch(
    "/{task_id}/status",
    response_model=CollectionTaskResponse
)
def update_task_status(
    task_id: int,
    update_data: CollectionTaskStatusUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("driver"))
):
    task = db.get(CollectionTask, task_id)

    if not task:
        raise HTTPException(
            status_code=404,
            detail="Collection task not found"
        )

    if task.worker_id != current_user.user_id:
        raise HTTPException(
            status_code=403,
            detail="You are not assigned to this task"
        )

    if task.status in ["completed", "cancelled"]:
        raise HTTPException(
            status_code=400,
            detail="This task can no longer be updated"
        )

    allowed_transitions = {
        "assigned": ["in_progress", "cancelled"],
        "in_progress": ["completed", "cancelled"]
    }

    if update_data.status not in allowed_transitions.get(task.status, []):
        raise HTTPException(
            status_code=400,
            detail=(
                f"Invalid task status transition from "
                f"{task.status} to {update_data.status}"
            )
        )

    complaint = db.get(Complaint, task.complaint_id)

    if not complaint:
        raise HTTPException(
            status_code=404,
            detail="Related complaint not found"
        )

    if complaint.status == "resolved":
        raise HTTPException(
            status_code=400,
            detail="The related complaint is already resolved"
        )

    driver_profile = db.query(DriverProfile).filter(
        DriverProfile.user_id == current_user.user_id
    ).first()

    old_complaint_status = complaint.status

    # Update task
    task.status = update_data.status

    if update_data.status == "completed":
        task.completed_at = datetime.now(timezone.utc)
    else:
        task.completed_at = None

    if update_data.completion_notes is not None:
        task.completion_notes = update_data.completion_notes

    if update_data.completion_photo_url is not None:
        media_id = update_data.completion_photo_url.rsplit("/", 1)[-1]
        asset = db.get(MediaAsset, media_id)
        if (
            not asset
            or asset.owner_user_id != current_user.user_id
            or asset.purpose != "task_completion"
        ):
            raise HTTPException(
                status_code=400,
                detail="Invalid completion image reference",
            )
        task.completion_photo_url = update_data.completion_photo_url

    # Synchronize complaint status
    if update_data.status == "in_progress":
        complaint.status = "in_progress"

    elif update_data.status == "completed":
        complaint.status = "resolved"

    elif update_data.status == "cancelled":
        if complaint.status in ["assigned", "in_progress"]:
            complaint.status = "pending"

    # Update driver availability
    if update_data.status in ["completed", "cancelled"] and driver_profile:
        db.flush()

        if not has_active_task(db, current_user.user_id):
            driver_profile.availability = "Available"

    # Notify citizen
    if update_data.status == "in_progress":
        notification = Notification(
            user_id=complaint.user_id,
            title="Collection Started",
            message=f"Collection has started for your complaint #{complaint.complaint_id}.",
            notification_type="complaint_update"
        )
        db.add(notification)

    elif update_data.status == "completed":
        notification = Notification(
            user_id=complaint.user_id,
            title="Complaint Resolved",
            message=f"Your complaint #{complaint.complaint_id} has been resolved.",
            notification_type="complaint_update"
        )
        db.add(notification)

    elif update_data.status == "cancelled":
        notification = Notification(
            user_id=complaint.user_id,
            title="Collection Cancelled",
            message=(
                f"The collection task for your complaint "
                f"#{complaint.complaint_id} has been cancelled. "
                "Your complaint is awaiting reassignment."
            ),
            notification_type="complaint_update"
        )
        db.add(notification)

    # Record complaint status history
    if old_complaint_status != complaint.status:
        history = ComplaintStatusHistory(
            complaint_id=complaint.complaint_id,
            old_status=old_complaint_status,
            new_status=complaint.status,
            changed_by=current_user.user_id,
            remarks=update_data.completion_notes
        )
        db.add(history)

    try:
        db.commit()
        db.refresh(task)

        return task

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Could not update collection task status"
        )
