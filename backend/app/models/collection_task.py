from datetime import datetime

from sqlalchemy import (
    BigInteger,
    ForeignKey,
    Identity,
    String,
    DateTime,
    Text,
    text,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class CollectionTask(Base):
    __tablename__ = "collection_tasks"

    task_id: Mapped[int] = mapped_column(
        BigInteger,
        Identity(always=True),
        primary_key=True
    )

    complaint_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("complaints.complaint_id"),
        nullable=False
    )

    worker_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("users.user_id"),
        nullable=False
    )

    scheduled_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True
    )

    status: Mapped[str] = mapped_column(
        String,
        nullable=False,
        server_default=text("'assigned'")
    )

    completed_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True
    )

    assigned_by: Mapped[int | None] = mapped_column(
        BigInteger,
        ForeignKey("users.user_id"),
        nullable=True
    )

    completion_notes: Mapped[str | None] = mapped_column(
        Text,
        nullable=True
    )

    completion_photo_url: Mapped[str | None] = mapped_column(
        Text,
        nullable=True
    )