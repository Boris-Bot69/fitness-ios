"""Factories to help in tests."""
from factory import PostGenerationMethodCall, Sequence
from factory.alchemy import SQLAlchemyModelFactory

from tumsm_server.patient.models import Patient
from tumsm_server.database import db
from tumsm_server.user.models import User


class BaseFactory(SQLAlchemyModelFactory):
    """Base factory."""

    class Meta:
        """Factory configuration."""

        abstract = True
        sqlalchemy_session = db.session


class UserFactory(BaseFactory):
    """User factory."""

    username = Sequence(lambda n: f"user{n}")
    email = Sequence(lambda n: f"user{n}@example.com")
    password = PostGenerationMethodCall("set_password", "example")
    active = True

    class Meta:
        """Factory configuration."""

        model = User


class PatientFactory(BaseFactory):
    """Patient factory."""

    username = Sequence(lambda n: f"patient{n}")
    email = Sequence(lambda n: f"patient{n}@example.com")
    password = PostGenerationMethodCall("set_password", "example")
    active = True

    class Meta:
        """Factory configuration."""

        model = Patient
