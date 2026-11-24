from typing import Literal
from pydantic import BaseModel


class ComplaintStatusUpdate(BaseModel):
    status: Literal["pending", "in_progress", "resolved"]
    notes: str | None = None