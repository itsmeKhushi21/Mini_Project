
from datetime import datetime

from pydantic import BaseModel, Field, ConfigDict


class GarbageBinCreate(BaseModel):
    bin_code: str = Field(min_length=2, max_length=50)
    location: str = Field(min_length=3)
    waste_type: str = Field(min_length=2, max_length=50)
    capacity: str = Field(min_length=1, max_length=50)

    condition: str = "Good"
    fill_level: int = Field(default=50, ge=0, le=100)

    latitude: float | None = None
    longitude: float | None = None

    requires_collection: bool = False
    is_damaged: bool = False


class GarbageBinUpdate(BaseModel):
    location: str | None = Field(default=None, min_length=3)
    waste_type: str | None = Field(default=None, min_length=2, max_length=50)
    capacity: str | None = Field(default=None, min_length=1, max_length=50)
    condition: str | None = Field(default=None, max_length=30)

    fill_level: int | None = Field(default=None, ge=0, le=100)

    latitude: float | None = None
    longitude: float | None = None

    requires_collection: bool | None = None
    is_damaged: bool | None = None


class GarbageBinResponse(BaseModel):
    bin_id: int
    bin_code: str
    location: str
    waste_type: str
    capacity: str | None

    condition: str
    fill_level: int

    latitude: float | None
    longitude: float | None

    requires_collection: bool
    is_damaged: bool

    last_collection: datetime | None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
