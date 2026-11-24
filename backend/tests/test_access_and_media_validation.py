import unittest
from datetime import datetime, timezone
from pathlib import Path
from tempfile import TemporaryDirectory
from types import SimpleNamespace
from unittest.mock import patch

from fastapi import FastAPI, HTTPException
from fastapi.testclient import TestClient

from app.models.complaint import Complaint
from app.routes.complaint_history import get_complaint_history
from app.models.driver_profile import DriverProfile
from app.routes.driver_profiles import _profile_response, router as driver_profiles_router
from app.models.media_asset import MediaAsset
from app.routes.media import _image_type, router as media_router
from app.schemas.complaints import ComplaintCreate
from app.schemas.driver_profiles import DriverProfileResponse
from app.schemas.garbage_bins import GarbageBinResponse
from app.database import get_db
from app.utils.dependencies import get_current_user, require_roles
from pydantic import ValidationError


class _ProfileQuery:
    def __init__(self, value):
        self.value = value

    def filter(self, *args, **kwargs):
        return self

    def first(self):
        return self.value


class _DriverProfileDatabase:
    def __init__(self):
        self.profile = SimpleNamespace(
            driver_profile_id=23,
            user_id=41,
            employee_id="DRV-EXISTING",
            vehicle_registration="ABC-123",
            availability="Available",
            created_at=datetime.now(timezone.utc),
        )
        self.commit_count = 0

    def query(self, model):
        return _ProfileQuery(self.profile if model is DriverProfile else None)

    def commit(self):
        self.commit_count += 1

    def refresh(self, value):
        return None

    def rollback(self):
        return None


class _HistoryQuery:
    def filter(self, *args, **kwargs):
        return self

    def order_by(self, *args, **kwargs):
        return self

    def all(self):
        return []


class _HistoryDatabase:
    def __init__(self, owner_id):
        self.owner_id = owner_id

    def get(self, model, key):
        if model is Complaint and key == 1:
            return SimpleNamespace(user_id=self.owner_id)
        return None

    def query(self, model):
        return _HistoryQuery()


class _MediaDatabase:
    def __init__(self):
        self.assets = {}
        self.current_user = None
        self.complaint = None
        self.assigned_driver_ids = set()

    def add(self, asset):
        self.assets[asset.media_id] = asset

    def commit(self):
        return None

    def rollback(self):
        return None

    def get(self, model, key):
        if model is MediaAsset:
            return self.assets.get(key)
        return None

    def query(self, model):
        return _MediaAccessQuery(self, model)


class _MediaAccessQuery:
    def __init__(self, database, model):
        self.database = database
        self.model = model

    def filter(self, *args, **kwargs):
        return self

    def first(self):
        if self.model is Complaint:
            return self.database.complaint
        if self.database.current_user.user_id in self.database.assigned_driver_ids:
            return SimpleNamespace()
        return None


class AccessAndMediaValidationTests(unittest.TestCase):
    def test_complaint_schema_rejects_too_short_description_and_location(self):
        with self.assertRaises(ValidationError):
            ComplaintCreate(
                description="bad",
                location="Main Street",
                waste_type="Plastic",
            )

        with self.assertRaises(ValidationError):
            ComplaintCreate(
                description="Overflowing garbage",
                location="X",
                waste_type="Plastic",
            )

    def test_driver_profile_response_includes_name_and_existing_ids(self):
        created_at = "2026-01-01T00:00:00+00:00"
        profile = SimpleNamespace(
            driver_profile_id=23,
            user_id=41,
            employee_id="DRV-EXISTING",
            vehicle_registration="ABC-123",
            availability="Available",
            created_at=created_at,
        )

        response = DriverProfileResponse.model_validate(
            _profile_response(profile, "Ankith")
        )

        self.assertEqual(response.full_name, "Ankith")
        self.assertEqual(response.employee_id, "DRV-EXISTING")
        self.assertEqual(response.user_id, 41)
        self.assertEqual(response.driver_profile_id, 23)

    def test_bin_response_accepts_database_nullable_capacity(self):
        response = GarbageBinResponse.model_validate(
            {
                "bin_id": 5,
                "bin_code": "BIN-5",
                "location": "Main Street",
                "waste_type": "Mixed waste",
                "capacity": None,
                "condition": "Good",
                "fill_level": 50,
                "latitude": None,
                "longitude": None,
                "requires_collection": False,
                "is_damaged": False,
                "last_collection": None,
                "created_at": datetime.now(timezone.utc),
            }
        )

        self.assertIsNone(response.capacity)

    def test_citizen_can_read_only_own_complaint_history(self):
        own_history = get_complaint_history(
            1,
            _HistoryDatabase(owner_id=10),
            SimpleNamespace(user_id=10, role="citizen"),
        )
        self.assertEqual(own_history, [])

        with self.assertRaises(HTTPException) as raised:
            get_complaint_history(
                1,
                _HistoryDatabase(owner_id=10),
                SimpleNamespace(user_id=11, role="citizen"),
            )
        self.assertEqual(raised.exception.status_code, 403)

    def test_role_guard_rejects_non_admin(self):
        with self.assertRaises(HTTPException) as raised:
            require_roles("admin")(SimpleNamespace(role="citizen"))
        self.assertEqual(raised.exception.status_code, 403)

    def test_driver_can_update_own_availability_but_not_another_driver(self):
        app = FastAPI()
        app.include_router(driver_profiles_router)
        database = _DriverProfileDatabase()
        driver = SimpleNamespace(
            user_id=41,
            role="driver",
            full_name="Test Driver",
        )
        app.dependency_overrides[get_db] = lambda: database
        app.dependency_overrides[get_current_user] = lambda: driver

        with TestClient(app) as client:
            responses = [
                client.patch(
                    "/driver-profiles/me",
                    json={"availability": availability},
                )
                for availability in ("Available", "Busy", "Off Duty")
            ]
            other_driver_response = client.patch(
                "/driver-profiles/99",
                json={"availability": "Busy"},
            )

        self.assertEqual([response.status_code for response in responses], [200] * 3)
        self.assertEqual(
            [response.json()["availability"] for response in responses],
            ["Available", "Busy", "Off Duty"],
        )
        self.assertEqual(database.profile.availability, "Off Duty")
        self.assertEqual(database.commit_count, 3)
        self.assertEqual(other_driver_response.status_code, 403)

    def test_media_type_uses_image_signatures(self):
        self.assertEqual(_image_type(b"\xff\xd8\xffdata"), ("image/jpeg", ".jpg"))
        self.assertEqual(
            _image_type(b"\x89PNG\r\n\x1a\ndata"),
            ("image/png", ".png"),
        )
        self.assertEqual(
            _image_type(b"RIFFxxxxWEBPdata"),
            ("image/webp", ".webp"),
        )
        self.assertIsNone(_image_type(b"not an image"))
        self.assertIsNone(_image_type(b"RIFFxxxxNOPE"))

    def test_uploaded_image_is_saved_and_retrievable_by_its_owner(self):
        app = FastAPI()
        app.include_router(media_router)
        database = _MediaDatabase()
        owner = SimpleNamespace(user_id=41, role="citizen")
        app.dependency_overrides[get_db] = lambda: database
        app.dependency_overrides[get_current_user] = lambda: owner
        image_bytes = b"\xff\xd8\xffstored-test-image"

        with TemporaryDirectory() as temp_dir:
            with patch("app.routes.media.STORAGE_DIR", Path(temp_dir)):
                with TestClient(app) as client:
                    uploaded = client.post(
                        "/media",
                        content=image_bytes,
                        headers={
                            "Content-Type": "application/octet-stream",
                            "X-Upload-Purpose": "complaint",
                        },
                    )

                    self.assertEqual(uploaded.status_code, 201)
                    image_url = uploaded.json()["url"]
                    media_id = uploaded.json()["media_id"]
                    asset = database.get(MediaAsset, media_id)
                    self.assertIsNotNone(asset)
                    self.assertEqual(
                        (Path(temp_dir) / asset.storage_name).read_bytes(),
                        image_bytes,
                    )

                    fetched = client.get(image_url)
                    self.assertEqual(fetched.status_code, 200)
                    self.assertEqual(fetched.content, image_bytes)

                    app.dependency_overrides[get_current_user] = lambda: (
                        SimpleNamespace(user_id=99, role="citizen")
                    )
                    forbidden = client.get(image_url)
                    self.assertEqual(forbidden.status_code, 403)

    def test_complaint_image_is_available_to_assigned_manager_and_driver_only(self):
        app = FastAPI()
        app.include_router(media_router)
        database = _MediaDatabase()
        media_id = "test-media-id"
        image_bytes = b"\xff\xd8\xffcomplaint-image"
        database.assets[media_id] = MediaAsset(
            media_id=media_id,
            owner_user_id=41,
            purpose="complaint",
            storage_name=f"{media_id}.jpg",
            content_type="image/jpeg",
            file_size=len(image_bytes),
        )
        database.complaint = SimpleNamespace(
            complaint_id=31,
            photo_url=f"/media/{media_id}",
            assigned_manager_id=51,
        )
        database.assigned_driver_ids.add(61)
        app.dependency_overrides[get_db] = lambda: database
        app.dependency_overrides[get_current_user] = lambda: database.current_user

        with TemporaryDirectory() as temp_dir:
            with patch("app.routes.media.STORAGE_DIR", Path(temp_dir)):
                Path(temp_dir, f"{media_id}.jpg").write_bytes(image_bytes)
                with TestClient(app) as client:
                    database.current_user = SimpleNamespace(
                        user_id=51, role="manager"
                    )
                    manager_response = client.get(f"/media/{media_id}")
                    self.assertEqual(manager_response.status_code, 200)
                    self.assertEqual(manager_response.content, image_bytes)

                    database.current_user = SimpleNamespace(
                        user_id=52, role="manager"
                    )
                    other_manager_response = client.get(f"/media/{media_id}")
                    self.assertEqual(other_manager_response.status_code, 403)

                    database.current_user = SimpleNamespace(
                        user_id=61, role="driver"
                    )
                    driver_response = client.get(f"/media/{media_id}")
                    self.assertEqual(driver_response.status_code, 200)
                    self.assertEqual(driver_response.content, image_bytes)

                    database.current_user = SimpleNamespace(
                        user_id=62, role="driver"
                    )
                    other_driver_response = client.get(f"/media/{media_id}")
                    self.assertEqual(other_driver_response.status_code, 403)

                    database.current_user = SimpleNamespace(
                        user_id=99, role="citizen"
                    )
                    unauthorized_response = client.get(f"/media/{media_id}")
                    self.assertEqual(unauthorized_response.status_code, 403)


if __name__ == "__main__":
    unittest.main()
