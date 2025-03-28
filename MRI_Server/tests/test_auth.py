import collections
import json

from .factories import PatientFactory
from .helpers import get_patient_username

API_VERSION = "v1"


def test_authenticate_patient(patient, testapp):
    """Authenticate patient that is registered."""
    patient = get_patient_username(testapp)
    resp = testapp.post_json(
        f"/api/{API_VERSION}/auth",
        {"username": patient, "password": "myprecious"},
    )
    assert "token" in resp.json, "correct credentials should yield token"


def test_authenticate_patient_wrong_credentials(patient, testapp):
    """Authenticate patient with wrong credentials."""
    patient = get_patient_username(testapp)
    resp = testapp.post_json(
        f"/api/{API_VERSION}/auth",
        {"username": patient, "password": "not-correct"},
        expect_errors=True,
        status=401,
    )
    assert "msg" in resp.json, "response should include error message"
    assert "password" in resp.json["msg"], "error message should mention the root cause"

    resp = testapp.post_json(
        f"/api/{API_VERSION}/auth",
        {"username": "patient-not-registered", "password": "doesnt-matter"},
        expect_errors=True,
        status=401,
    )
    assert resp.status_code == 401, "incorrect username should produce 401 error"
    assert "msg" in resp.json, "response should include error message"
    assert "username" in resp.json["msg"], "error message should mention the root cause"


def test_get_patient_data(testapp_authorized):
    """Get patient data."""
    resp = testapp_authorized.get(f"/api/{API_VERSION}/patients/statistics")
    assert "username" in resp.json
    assert resp.json["workouts"] == 0
