from datetime import datetime

from sqlalchemy import (
    BigInteger,
    String,
    Text,
    DateTime,
    ForeignKey,
    Identity,
)
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func

from app.models.base import Base


class ComplaintStatusHistory(Base):
    __tablename__ = "complaint_status_history"

    history_id: Mapped[int] = mapped_column(
        BigInteger, Identity(always=True), primary_key=True
    )

    complaint_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("complaints.complaint_id"),
        nullable=False
    )

    old_status: Mapped[str | None] = mapped_column(
        String, nullable=True
    )

    new_status: Mapped[str] = mapped_column(
        String, nullable=False
    )

    changed_by: Mapped[int | None] = mapped_column(
        BigInteger,
        ForeignKey("users.user_id"),
        nullable=True
    )

    remarks: Mapped[str | None] = mapped_column(
        Text, nullable=True
    )

    changed_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now()
    )