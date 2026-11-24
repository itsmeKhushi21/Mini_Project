
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.complaint_status_history import ComplaintStatusHistory
from app.models.user import User

from app.schemas.complaint_status_history import (
    ComplaintStatusHistoryResponse
)

from app.utils.dependencies import require_roles
from app.models.complaint import Complaint


router = APIRouter(
    prefix="/complaints",
    tags=["Complaint Status History"]
)


# Manager views the status history of a complaint
@router.get(
    "/{complaint_id}/history",
    response_model=list[ComplaintStatusHistoryResponse]
)
def get_complaint_history(
    complaint_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_roles("manager", "citizen", "admin"))
):
    complaint = db.get(Complaint, complaint_id)
    if not complaint:
        raise HTTPException(status_code=404, detail="Complaint not found")
    if current_user.role == "citizen" and complaint.user_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="You can only view your own complaint history")
    history = db.query(ComplaintStatusHistory).filter(
        ComplaintStatusHistory.complaint_id == complaint_id
    ).order_by(
        ComplaintStatusHistory.changed_at.desc()
    ).all()

    return history
