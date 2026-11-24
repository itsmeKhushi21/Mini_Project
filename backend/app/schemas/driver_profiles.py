from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field, ConfigDict


class DriverProfileUpdate(BaseModel):
    employee_id: str | None = Field(default=None, max_length=50)
    vehicle_registration: str | None = Field(default=None, max_length=30)
    availability: Literal["Available", "Busy", "Off Duty"] | None = None


class DriverProfileResponse(BaseModel):
    driver_profile_id: int
    user_id: int
    full_name: str | None = None
    employee_id: str | None
    vehicle_registration: str | None
    availability: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)