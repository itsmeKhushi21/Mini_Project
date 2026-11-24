
from getpass import getpass

from sqlalchemy import select

from app.database import SessionLocal
from app.models.user import User
from app.utils.security import hash_password


def create_admin():
    print("\n=== Create Initial Admin Account ===\n")

    full_name = input("Admin full name: ").strip()
    email = input("Admin email: ").strip().lower()
    phone = input("Phone number (optional): ").strip() or None

    password = getpass("Enter admin password: ")
    confirm_password = getpass("Confirm admin password: ")

    if len(full_name) < 2:
        print("Error: Full name must contain at least 2 characters.")
        return

    if "@" not in email or "." not in email:
        print("Error: Enter a valid email address.")
        return

    if len(password) < 8:
        print("Error: Password must contain at least 8 characters.")
        return

    if password != confirm_password:
        print("Error: Passwords do not match.")
        return

    db = SessionLocal()

    try:
        existing_user = db.scalar(
            select(User).where(User.email == email)
        )

        if existing_user:
            print("Error: This email is already registered.")
            return

        admin = User(
            full_name=full_name,
            email=email,
            password_hash=hash_password(password),
            role="admin",
            phone=phone,
            is_active=True,
            created_by_user_id=None,
        )

        db.add(admin)
        db.commit()
        db.refresh(admin)

        print("\nAdmin account created successfully!")
        print("Admin ID:", admin.user_id)
        print("Admin email:", admin.email)
        print("Admin role:", admin.role)

    except Exception as error:
        db.rollback()
        print("Admin creation failed:", error)

    finally:
        db.close()


if __name__ == "__main__":
    create_admin()
