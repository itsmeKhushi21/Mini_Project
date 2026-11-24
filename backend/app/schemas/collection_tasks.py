
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


# Driver task complaint details
class DriverTaskComplaintDetails(BaseModel):
    description: str
    location: str
    waste_type: str
    priority: str
    latitude: float | None = None
    longitude: float | None = None
    photo_url: str | None = None


# Driver task customer details
class DriverTaskCustomerDetails(BaseModel):
    full_name: str
    phone: str | None = None


# Complete task response for driver
class DriverAssignedTaskResponse(BaseModel):
    task_id: int
    complaint_id: int
    worker_id: int
    scheduled_at: datetime | None = None
    status: str
    completed_at: datetime | None = None
    completion_notes: str | None = None
    completion_photo_url: str | None = None
    complaint: DriverTaskComplaintDetails
    customer: DriverTaskCustomerDetails


# Create collection task
class CollectionTaskCreate(BaseModel):
    complaint_id: int = Field(gt=0)
    worker_id: int = Field(gt=0)
    scheduled_at: datetime | None = None


# Update collection task status
class CollectionTaskStatusUpdate(BaseModel):
    status: Literal[
        "assigned",
        "in_progress",
        "completed",
        "cancelled"
    ]
    completion_notes: str | None = None
    completion_photo_url: str | None = None


# Standard collection task response
class CollectionTaskResponse(BaseModel):
    task_id: int
    complaint_id: int
    worker_id: int
    scheduled_at: datetime | None
    status: str
    completed_at: datetime | None
    assigned_by: int | None
    completion_notes: str | None
    completion_photo_url: str | None

    model_config = {"from_attributes": True}
