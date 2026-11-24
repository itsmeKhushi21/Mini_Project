from datetime import datetime

from sqlalchemy import BigInteger, DateTime, ForeignKey, String, Text, text
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func

from app.models.base import Base


class DriverIssue(Base):
    __tablename__ = "driver_issues"

    issue_id: Mapped[int] = mapped_column(
        BigInteger, primary_key=True, autoincrement=True
    )
    driver_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("users.user_id"), nullable=False, index=True
    )
    task_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("collection_tasks.task_id"), nullable=False, index=True
    )
    issue_type: Mapped[str] = mapped_column(String(80), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    photo_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[str] = mapped_column(
        String(30), nullable=False, server_default=text("'Reported'")
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
