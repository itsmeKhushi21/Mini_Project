
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field, ConfigDict


class BinMaintenanceCreate(BaseModel):
    bin_id: int = Field(gt=0)
    description: str = Field(min_length=5)


class BinMaintenanceUpdate(BaseModel):
    maintenance_status: Literal[
        "Reported",
        "In Progress",
        "Completed",
        "Cancelled"
    ]


class BinMaintenanceResponse(BaseModel):
    maintenance_id: int
    bin_id: int
    reported_by: int | None
    description: str
    maintenance_status: str
    reported_at: datetime
    completed_at: datetime | None

    model_config = ConfigDict(from_attributes=True)
