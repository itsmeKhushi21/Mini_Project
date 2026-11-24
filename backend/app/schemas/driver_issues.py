from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


class DriverIssueCreate(BaseModel):
    task_id: int = Field(gt=0)
    issue_type: str = Field(min_length=2, max_length=80)
    description: str = Field(min_length=5, max_length=4000)
    photo_url: str | None = Field(default=None, max_length=200)


class DriverIssueStatusUpdate(BaseModel):
    status: Literal["In Progress", "Resolved", "Dismissed"]


class DriverIssueResponse(BaseModel):
    issue_id: int
    driver_id: int
    task_id: int
    issue_type: str
    description: str
    photo_url: str | None
    status: str
    created_at: datetime

    model_config = {"from_attributes": True}
