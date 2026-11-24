from datetime import datetime
from pydantic import BaseModel, Field


class ComplaintCreate(BaseModel):
    description: str = Field(min_length=5)
    location: str = Field(min_length=3)
    waste_type: str = Field(min_length=2)
    priority: str = "Medium"
    notes: str | None = None
    photo_url: str | None = None
    latitude: float | None = None
    longitude: float | None = None


class ComplaintResponse(BaseModel):
    complaint_id: int
    user_id: int
    description: str
    location: str
    waste_type: str
    status: str
    created_at: datetime
    priority: str
    notes: str | None
    photo_url: str | None
    latitude: float | None
    longitude: float | None
    assigned_manager_id: int | None

    model_config = {"from_attributes": True}