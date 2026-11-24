from datetime import datetime

from sqlalchemy import (
    BigInteger,
    String,
    Text,
    Boolean,
    DateTime,
    ForeignKey,
    text
)
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func

from app.models.base import Base


class User(Base):
    __tablename__ = "users"

    user_id: Mapped[int] = mapped_column(
        BigInteger, primary_key=True
    )

    full_name: Mapped[str] = mapped_column(
        String(100), nullable=False
    )

    email: Mapped[str] = mapped_column(
        String(255), unique=True, nullable=False
    )

    password_hash: Mapped[str] = mapped_column(
        Text, nullable=False
    )

    role: Mapped[str] = mapped_column(
        String(20), nullable=False, server_default=text("'citizen'")
    )

    phone: Mapped[str | None] = mapped_column(
        String(20), nullable=True
    )

    is_active: Mapped[bool] = mapped_column(
        Boolean, nullable=False, server_default=text("true")
    )

    created_by_user_id: Mapped[int | None] = mapped_column(
        BigInteger, ForeignKey("users.user_id"), nullable=True
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )