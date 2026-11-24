
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.notification import Notification
from app.models.user import User
from app.schemas.notifications import NotificationResponse
from app.utils.dependencies import get_current_user

router = APIRouter(prefix="/notifications", tags=["Notifications"])


# Get logged-in user's notifications
@router.get("/my", response_model=list[NotificationResponse])
def get_my_notifications(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return (
        db.query(Notification)
        .filter(Notification.user_id == current_user.user_id)
        .order_by(Notification.created_at.desc())
        .all()
    )


# Get unread notification count
@router.get("/unread-count")
def get_unread_count(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    count = (
        db.query(Notification)
        .filter(
            Notification.user_id == current_user.user_id,
            Notification.is_read == False
        )
        .count()
    )

    return {"unread_count": count}


# Mark one notification as read
@router.patch("/{notification_id}/read")
def mark_notification_read(
    notification_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    notification = db.query(Notification).filter(
        Notification.notification_id == notification_id,
        Notification.user_id == current_user.user_id
    ).first()

    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")

    notification.is_read = True

    try:
        db.commit()
        return {"message": "Notification marked as read"}
    except Exception:
        db.rollback()
        raise HTTPException(status_code=500, detail="Could not update notification")


# Mark all notifications as read
@router.patch("/read-all")
def mark_all_notifications_read(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        db.query(Notification).filter(
            Notification.user_id == current_user.user_id,
            Notification.is_read == False
        ).update(
            {Notification.is_read: True},
            synchronize_session=False
        )

        db.commit()
        return {"message": "All notifications marked as read"}

    except Exception:
        db.rollback()
        raise HTTPException(status_code=500, detail="Could not update notifications")
