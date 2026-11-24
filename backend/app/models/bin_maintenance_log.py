
from datetime import datetime

from sqlalchemy import (
    BigInteger,
    Text,
    String,
    DateTime,
    ForeignKey,
    Identity,
)
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func

from app.models.base import Base


class BinMaintenanceLog(Base):
    __tablename__ = "bin_maintenance_logs"

    maintenance_id: Mapped[int] = mapped_column(
        BigInteger, Identity(always=True), primary_key=True
    )

    bin_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("garbage_bins.bin_id"),
        nullable=False
    )

    reported_by: Mapped[int | None] = mapped_column(
        BigInteger,
        ForeignKey("users.user_id"),
        nullable=True
    )

    description: Mapped[str] = mapped_column(
        Text, nullable=False
    )

    maintenance_status: Mapped[str] = mapped_column(
        String,
        nullable=False,
        server_default="'Reported'"
    )

    reported_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now()
    )

    completed_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True
    )
