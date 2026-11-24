
from datetime import datetime

from sqlalchemy import (
    BigInteger,
    Integer,
    Text,
    DateTime,
    ForeignKey,
    Identity,
)
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func

from app.models.base import Base


class BinCollectionLog(Base):
    __tablename__ = "bin_collection_logs"

    collection_log_id: Mapped[int] = mapped_column(
        BigInteger, Identity(always=True), primary_key=True
    )

    bin_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("garbage_bins.bin_id"),
        nullable=False
    )

    driver_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("users.user_id"),
        nullable=False
    )

    collected_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now()
    )

    fill_level_before: Mapped[int | None] = mapped_column(
        Integer, nullable=True
    )

    notes: Mapped[str | None] = mapped_column(
        Text, nullable=True
    )

    photo_url: Mapped[str | None] = mapped_column(
        Text, nullable=True
    )
