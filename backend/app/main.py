
import os

from fastapi import FastAPI, HTTPException
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from fastapi.middleware.cors import CORSMiddleware

from app.database import engine

# Import routers
from app.routes.auth import router as auth_router
from app.routes.users import router as users_router
from app.routes.complaints import router as complaints_router
from app.routes.tasks import router as tasks_router
from app.routes.bins import router as bins_router
from app.routes.schedules import router as schedules_router
from app.routes.driver_profiles import router as driver_profiles_router
from app.routes.complaint_history import router as complaint_history_router
from app.routes.bin_collection_logs import router as bin_collection_logs_router
from app.routes.bin_maintenance_logs import router as bin_maintenance_logs_router
from app.routes.dashboard import router as dashboard_router
from app.routes.citizen_dashboard import router as citizen_dashboard_router
from app.routes.driver_dashboard import router as driver_dashboard_router
from app.routes.admin_dashboard import router as admin_dashboard_router
from app.routes.notifications import router as notifications_router
from app.routes.media import router as media_router
from app.routes.driver_issues import router as driver_issues_router

# Initialize FastAPI application
app = FastAPI(
    title="Garbage Management System API",
    description="Backend API for Garbage Management System",
    version="1.0.0"
)

# CORS configuration for Flutter Web development
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_origins=[
        origin.strip()
        for origin in os.getenv("CORS_ALLOWED_ORIGINS", "").split(",")
        if origin.strip()
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register API routers
app.include_router(auth_router)
app.include_router(users_router)
app.include_router(complaints_router)
app.include_router(tasks_router)
app.include_router(bins_router)
app.include_router(schedules_router)
app.include_router(driver_profiles_router)
app.include_router(complaint_history_router)
app.include_router(bin_collection_logs_router)
app.include_router(bin_maintenance_logs_router)
app.include_router(dashboard_router)
app.include_router(citizen_dashboard_router)
app.include_router(driver_dashboard_router)
app.include_router(admin_dashboard_router)
app.include_router(notifications_router)
app.include_router(media_router)
app.include_router(driver_issues_router)


# Home endpoint
@app.get("/")
def home():
    return {
        "message": "Garbage Management Backend is running!"
    }


# Database health check
@app.get("/db-health")
def database_health():
    try:
        with engine.connect() as connection:
            result = connection.execute(
                text("SELECT current_database(), current_user")
            )

            database_name, username = result.fetchone()

        return {
            "status": "success",
            "message": "PostgreSQL connected successfully!",
            "database": database_name,
            "user": username
        }

    except SQLAlchemyError:
        raise HTTPException(
            status_code=500,
            detail="Database connection failed. Check your configuration."
        )
