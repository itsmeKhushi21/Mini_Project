
from datetime import datetime

from sqlalchemy import (
    BigInteger,
    String,
    DateTime,
    ForeignKey,
    Identity,
    text,
)
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func

from app.models.base import Base


class DriverProfile(Base):
    __tablename__ = "driver_profiles"

    driver_profile_id: Mapped[int] = mapped_column(
        BigInteger,
        Identity(always=True),
        primary_key=True
    )

    user_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("users.user_id"),
        nullable=False
    )

    employee_id: Mapped[str | None] = mapped_column(
        String(50),
        nullable=True
    )

    vehicle_registration: Mapped[str | None] = mapped_column(
        String(30),
        nullable=True
    )

    availability: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
        server_default=text("'Available'")
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False
    )