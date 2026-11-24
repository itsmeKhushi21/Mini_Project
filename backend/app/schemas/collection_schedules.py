
from datetime import datetime
from pydantic import BaseModel, Field, ConfigDict


class CollectionScheduleCreate(BaseModel):
    waste_type: str = Field(min_length=2, max_length=50)
    area: str = Field(min_length=3)
    driver_id: int = Field(gt=0)
    vehicle: str | None = Field(default=None, max_length=50)
    starts_at: datetime
    time_slot: str | None = Field(default=None, max_length=50)


class CollectionScheduleUpdate(BaseModel):
    waste_type: str | None = Field(default=None, min_length=2, max_length=50)
    area: str | None = Field(default=None, min_length=3)
    driver_id: int | None = Field(default=None, gt=0)
    vehicle: str | None = Field(default=None, max_length=50)
    starts_at: datetime | None = None
    time_slot: str | None = Field(default=None, max_length=50)
    status: str | None = Field(default=None, max_length=30)


class CollectionScheduleResponse(BaseModel):
    schedule_id: int
    waste_type: str
    area: str
    driver_id: int
    vehicle: str | None
    starts_at: datetime
    time_slot: str | None
    status: str
    created_by: int | None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
