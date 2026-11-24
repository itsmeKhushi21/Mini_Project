
from datetime import datetime

from sqlalchemy import (
    BigInteger,
    String,
    Text,
    Integer,
    Float,
    Boolean,
    DateTime,
    Identity,
    text,
)
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func

from app.models.base import Base


class GarbageBin(Base):
    __tablename__ = "garbage_bins"

    bin_id: Mapped[int] = mapped_column(
        BigInteger,
        Identity(always=True),
        primary_key=True
    )

    bin_code: Mapped[str] = mapped_column(
        String(50),
        nullable=False
    )

    location: Mapped[str] = mapped_column(
        Text,
        nullable=False
    )

    waste_type: Mapped[str] = mapped_column(
        String(50),
        nullable=False
    )

    capacity: Mapped[str | None] = mapped_column(
        String(50),
        nullable=True
    )

    condition: Mapped[str] = mapped_column(
        String(30),
        nullable=False,
        server_default=text("'Good'")
    )

    fill_level: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        server_default=text("50")
    )

    latitude: Mapped[float | None] = mapped_column(
        Float,
        nullable=True
    )

    longitude: Mapped[float | None] = mapped_column(
        Float,
        nullable=True
    )

    requires_collection: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        server_default=text("false")
    )

    is_damaged: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        server_default=text("false")
    )

    last_collection: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now()
    )
