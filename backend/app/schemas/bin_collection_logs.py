
from datetime import datetime

from pydantic import BaseModel, Field, ConfigDict


class BinCollectionLogCreate(BaseModel):
    bin_id: int = Field(gt=0)
    fill_level_before: int | None = Field(default=None, ge=0, le=100)
    notes: str | None = None
    photo_url: str | None = None


class BinCollectionLogResponse(BaseModel):
    collection_log_id: int
    bin_id: int
    driver_id: int
    collected_at: datetime
    fill_level_before: int | None
    notes: str | None
    photo_url: str | None

    model_config = ConfigDict(from_attributes=True)
