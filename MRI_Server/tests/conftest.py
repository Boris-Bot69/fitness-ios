"""Defines fixtures available to all tests."""

import logging

import pytest
from webtest import TestApp

from tumsm_server.app import create_app
from tumsm_server.database import db as _db

from .factories import PatientFactory, UserFactory


@pytest.fixture
def app():
    """Create application for the tests."""
    _app = create_app("tests.settings")
    _app.logger.setLevel(logging.CRITICAL)
    ctx = _app.test_request_context()
    ctx.push()

    yield _app

    ctx.pop()


@pytest.fixture
def testapp(app):
    """Create Webtest app."""
    return TestApp(app)


@pytest.fixture
def testapp_authorized(testapp, patient):
    """Create Webtest app."""
    resp = testapp.get(f"/api/v1/patients")
    patients = [patient["username"] for patient in resp.json.values()]
    assert patients, "`patient` fixture should have provided at least one patient"

    # authenticate patient
    resp = testapp.post_json(
        f"/api/v1/auth",
        {"username": patients[0], "password": "myprecious"},
    )
    assert "token" in resp.json, "correct credentials should yield token"
    testapp.authorization = ("Bearer", resp.json["token"])

    return testapp


@pytest.fixture
def db(app):
    """Create database for the tests."""
    _db.app = app
    with app.app_context():
        _db.create_all()

    yield _db

    # Explicitly close DB connection
    _db.session.close()
    _db.drop_all()


@pytest.fixture
def user(db):
    """Create user for the tests."""
    user = UserFactory(password="myprecious")
    db.session.commit()
    return user


@pytest.fixture
def patient(db):
    """Create user for the tests."""
    patient = PatientFactory(password="myprecious")
    db.session.commit()
    return patient
