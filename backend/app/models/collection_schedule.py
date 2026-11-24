
from datetime import datetime

from sqlalchemy import (
    BigInteger,
    String,
    Text,
    DateTime,
    ForeignKey,
    Identity,
    text,
)
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func

from app.models.base import Base


class CollectionSchedule(Base):
    __tablename__ = "collection_schedules"

    schedule_id: Mapped[int] = mapped_column(
        BigInteger,
        Identity(always=True),
        primary_key=True
    )

    waste_type: Mapped[str] = mapped_column(
        String,
        nullable=False
    )

    area: Mapped[str] = mapped_column(
        Text,
        nullable=False
    )

    driver_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("users.user_id"),
        nullable=False
    )

    vehicle: Mapped[str | None] = mapped_column(
        String,
        nullable=True
    )

    starts_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False
    )

    time_slot: Mapped[str | None] = mapped_column(
        String,
        nullable=True
    )

    status: Mapped[str] = mapped_column(
        String,
        nullable=False,
        server_default=text("'Scheduled'")
    )

    created_by: Mapped[int | None] = mapped_column(
        BigInteger,
        ForeignKey("users.user_id"),
        nullable=True
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now()
    )
