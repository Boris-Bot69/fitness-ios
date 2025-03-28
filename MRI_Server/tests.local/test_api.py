#!/usr/bin/env python
import json

import requests

SERVER = "http://0.0.0.0:5000/api/v1"


def test_patients():
    patients = requests.get(SERVER + "/patients").json()
    print(patients)
    assert isinstance(patients, dict)


def test_auth_flow():
    resp = requests.post(
        SERVER + "/auth",
        json={"username": "patient", "password": "not-correct"},
    )
    print(resp.json())
    assert resp.status_code == 401, "incorrect password should produce 401 error"
    assert "msg" in resp.json(), "response should include error message"
    assert (
        "password" in resp.json()["msg"]
    ), "error message should mention the root cause"

    resp = requests.post(
        SERVER + "/auth",
        json={"username": "patient", "password": "password"},
    )
    print(resp.json())
    assert "token" in resp.json()
    token = resp.json()["token"]

    resp = requests.get(
        SERVER + "/patients/statistics", headers={"Authorization": f"Bearer {token}"}
    )
    print(resp.json())
    assert resp.json().get("username") == "patient"
