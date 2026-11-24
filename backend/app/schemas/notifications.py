
from datetime import datetime

from pydantic import BaseModel, Field, ConfigDict


class NotificationCreate(BaseModel):
    user_id: int = Field(gt=0)
    title: str = Field(min_length=2, max_length=150)
    message: str = Field(min_length=2)
    notification_type: str = Field(min_length=2, max_length=50)


class NotificationResponse(BaseModel):
    notification_id: int
    user_id: int
    title: str
    message: str
    notification_type: str
    is_read: bool
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class NotificationReadUpdate(BaseModel):
    is_read: bool
