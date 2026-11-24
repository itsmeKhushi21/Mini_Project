
from pydantic import BaseModel, Field, field_validator
import re


class StaffCreateRequest(BaseModel):
    full_name: str = Field(min_length=2, max_length=100)
    email: str = Field(max_length=255)
    password: str = Field(min_length=8, max_length=128)
    phone: str | None = Field(default=None, max_length=20)

    @field_validator("email")
    @classmethod
    def validate_email(cls, value):
        value = value.strip().lower()

        if not re.fullmatch(r"[^@\s]+@[^@\s]+\.[^@\s]+", value):
            raise ValueError("Enter a valid email address")

        return value


class DriverCreateRequest(StaffCreateRequest):
    employee_id: str | None = Field(default=None, max_length=50)
    vehicle_registration: str | None = Field(default=None, max_length=30)