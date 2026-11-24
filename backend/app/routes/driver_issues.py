from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.collection_task import CollectionTask
from app.models.driver_issue import DriverIssue
from app.models.media_asset import MediaAsset
from app.models.notification import Notification
from app.models.user import User
from app.schemas.driver_issues import (
    DriverIssueCreate,
    DriverIssueResponse,
    DriverIssueStatusUpdate,
)
from app.utils.dependencies import require_roles

router = APIRouter(prefix="/driver-issues", tags=["Driver Issues"])


@router.post("", response_model=DriverIssueResponse, status_code=status.HTTP_201_CREATED)
def create_driver_issue(
    data: DriverIssueCreate,
    db: Session = Depends(get_db),
    driver: User = Depends(require_roles("driver")),
):
    task = db.get(CollectionTask, data.task_id)
    if not task or task.worker_id != driver.user_id:
        raise HTTPException(status_code=404, detail="Assigned collection task not found")
    if task.status in {"completed", "cancelled"}:
        raise HTTPException(status_code=400, detail="Cannot report an issue for a closed task")

    if data.photo_url:
        media_id = data.photo_url.rsplit("/", 1)[-1]
        asset = db.get(MediaAsset, media_id)
        if not asset or asset.owner_user_id != driver.user_id or asset.purpose != "driver_issue":
            raise HTTPException(status_code=400, detail="Invalid issue image reference")

    issue = DriverIssue(
        driver_id=driver.user_id,
        task_id=task.task_id,
        issue_type=data.issue_type.strip(),
        description=data.description.strip(),
        photo_url=data.photo_url,
    )
    manager_ids = [task.assigned_by] if task.assigned_by else [
        row[0] for row in db.query(User.user_id).filter(
            User.role == "manager", User.is_active.is_(True)
        ).all()
    ]
    try:
        db.add(issue)
        db.flush()
        for manager_id in set(manager_ids):
            db.add(Notification(
                user_id=manager_id,
                title="Driver collection issue",
                message=f"Driver {driver.full_name} reported an issue for task #{task.task_id}.",
                notification_type="driver_issue",
            ))
        db.commit()
        db.refresh(issue)
        return issue
    except Exception:
        db.rollback()
        raise HTTPException(status_code=500, detail="Could not save driver issue")


@router.get("/my", response_model=list[DriverIssueResponse])
def get_my_driver_issues(
    db: Session = Depends(get_db),
    driver: User = Depends(require_roles("driver")),
):
    return db.query(DriverIssue).filter(
        DriverIssue.driver_id == driver.user_id
    ).order_by(DriverIssue.created_at.desc()).all()


@router.get("", response_model=list[DriverIssueResponse])
def get_driver_issues(
    db: Session = Depends(get_db),
    manager: User = Depends(require_roles("manager", "admin")),
):
    return db.query(DriverIssue).order_by(DriverIssue.created_at.desc()).all()


@router.patch("/{issue_id}/status", response_model=DriverIssueResponse)
def update_driver_issue_status(
    issue_id: int,
    data: DriverIssueStatusUpdate,
    db: Session = Depends(get_db),
    manager: User = Depends(require_roles("manager", "admin")),
):
    issue = db.get(DriverIssue, issue_id)
    if not issue:
        raise HTTPException(status_code=404, detail="Driver issue not found")
    if issue.status in {"Resolved", "Dismissed"}:
        raise HTTPException(status_code=400, detail="Driver issue is already closed")

    issue.status = data.status
    db.add(Notification(
        user_id=issue.driver_id,
        title="Driver issue updated",
        message=f"Issue #{issue.issue_id} status is now {data.status}.",
        notification_type="driver_issue_update",
    ))
    try:
        db.commit()
        db.refresh(issue)
        return issue
    except Exception:
        db.rollback()
        raise HTTPException(status_code=500, detail="Could not update driver issue")
