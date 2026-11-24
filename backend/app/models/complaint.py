from datetime import datetime

from sqlalchemy import (
    BigInteger,
    Text,
    String,
    DateTime,
    ForeignKey,
    Identity,
    Float,
    text,
)
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func

from app.models.base import Base


class Complaint(Base):
    __tablename__ = "complaints"

    complaint_id: Mapped[int] = mapped_column(
        BigInteger,
        Identity(always=True),
        primary_key=True
    )

    user_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("users.user_id"),
        nullable=False
    )

    description: Mapped[str] = mapped_column(
        Text,
        nullable=False
    )

    location: Mapped[str] = mapped_column(
        Text,
        nullable=False
    )

    waste_type: Mapped[str] = mapped_column(
        String,
        nullable=False
    )

    status: Mapped[str] = mapped_column(
        String,
        nullable=False,
        server_default=text("'pending'")
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now()
    )

    priority: Mapped[str] = mapped_column(
        String,
        nullable=False,
        server_default=text("'Medium'")
    )

    notes: Mapped[str | None] = mapped_column(
        Text,
        nullable=True
    )

    photo_url: Mapped[str | None] = mapped_column(
        Text,
        nullable=True
    )

    latitude: Mapped[float | None] = mapped_column(
        Float,
        nullable=True
    )

    longitude: Mapped[float | None] = mapped_column(
        Float,
        nullable=True
    )

    assigned_manager_id: Mapped[int | None] = mapped_column(
        BigInteger,
        ForeignKey("users.user_id"),
        nullable=True
    )