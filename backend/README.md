# Garbage Management System Backend

## Requirements

- Python 3.12+
- PostgreSQL

## Configuration

Copy `.env.example` to `.env`, then set the local PostgreSQL credentials and
a secure random JWT secret.

```powershell
Copy-Item .env.example .env
```

Do not commit `.env`.

## Install and run

```powershell
cd backend
py -m venv .venv
.\\.venv\\Scripts\\Activate.ps1
python -m pip install -r requirements.txt
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

## Database initialization

The application uses SQLAlchemy. Starting the app does not delete or reset
existing PostgreSQL records. To create missing tables from the current models:

```powershell
python -c "from app.database import engine; from app.models.base import Base; import app.models; Base.metadata.create_all(engine)"
```

For an explicit additive upgrade that creates the evidence and driver-issue
tables without altering existing records, apply the included SQL migration:

```powershell
psql -v ON_ERROR_STOP=1 -d garbage_management -f .\20260611_add_media_and_driver_issues.sql
```

Set `MEDIA_STORAGE_DIR` in `.env` to a persistent local path for uploaded
complaint and collection evidence. Uploads are limited to JPEG, PNG, and WebP
images up to 5 MB. Do not serve the upload directory directly; use the
authenticated `/media/{media_id}` endpoint.

Create an initial administrator interactively:

```powershell
python create_admin.py
```

## API documentation

- Swagger UI: `http://127.0.0.1:8000/docs`
- ReDoc: `http://127.0.0.1:8000/redoc`
- OpenAPI JSON: `http://127.0.0.1:8000/openapi.json`
- Database health: `http://127.0.0.1:8000/db-health`

For Flutter Web opened from a LAN hostname or IP address, add that exact origin
to `CORS_ALLOWED_ORIGINS` as a comma-separated value. Android emulator builds
should use `http://10.0.2.2:8000`; physical devices should use the development
computer's LAN IP and run Uvicorn with `--host 0.0.0.0`.
