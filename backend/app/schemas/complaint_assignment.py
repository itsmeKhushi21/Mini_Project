from pydantic import BaseModel, Field


class ComplaintAssignment(BaseModel):
    assigned_manager_id: int = Field(gt=0)