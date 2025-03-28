"""account models."""
import datetime as dt
import logging
import math

from flask_login import UserMixin

from tumsm_server.database import Column, PkModel, db, reference_col, relationship
from tumsm_server.extensions import bcrypt, jwt
from tumsm_server.utils import log_enter_and_exit, log, maxLoggingValueLength


class Account(UserMixin, PkModel):
    """An account used to log into the apps"""

    __tablename__ = "accounts"
    username = Column(db.String(80), unique=True, nullable=False)
    email = Column(db.String(80), unique=True, nullable=False)
    password = Column(db.LargeBinary(128), nullable=True)
    createdAt = Column(db.DateTime, nullable=False, default=dt.datetime.utcnow)
    createdById = reference_col("accounts", nullable=True)
    birthday = Column(db.Date, nullable=False)
    firstName = Column(db.String(30), nullable=True)
    lastName = Column(db.String(30), nullable=True)
    active = Column(db.Boolean(), default=False)

    patients = relationship("Patient", cascade="all,delete", backref="account")
    trainers = relationship("Trainer", cascade="all,delete", backref="account")

    def __init__(
        self, username, email, birthday, firstName, lastName, password=None, **kwargs
    ):
        log(
            f"> __init__ (username={username}, email={email}, birthday={birthday}, firstName={firstName}, "
            f"lastName={lastName})"
        )
        """Create instance."""
        super().__init__(
            username=username,
            email=email,
            birthday=birthday,
            firstName=firstName,
            lastName=lastName,
            **kwargs,
        )
        if password:
            self.set_password(password)
        else:
            self.password = None

    def update(self, commit=True, **kwargs):
        """Update specific fields of a record."""
        kwargs_rep = [
            f"{k}={v!r}"
            if len(repr(v)) < maxLoggingValueLength
            else f"{k}={repr(v)[: math.floor(maxLoggingValueLength / 2)]}...{repr(v)[math.floor(-maxLoggingValueLength / 2) :]}"
            for k, v in kwargs.items()
            if len(repr(v)) < maxLoggingValueLength and v != "password"
        ]
        log(f"({','.join(kwargs_rep)})")
        for attr, value in kwargs.items():
            if attr == "password":
                setattr(self, attr, bcrypt.generate_password_hash(value))
            else:
                setattr(self, attr, value)
        return commit and self.save() or self

    def set_password(self, password):
        """Set password."""
        self.password = bcrypt.generate_password_hash(password)

    def check_password(self, value):
        """Check password."""
        return bcrypt.check_password_hash(self.password, value)

    @property
    def full_name(self):
        """Full user name."""
        return f"{self.firstName} {self.lastName}"

    def __repr__(self):
        """Represent instance as a unique string."""
        return f"<Account({self.username})>"


# enable automatic user loading via `flask_jwt_extended` according to
# https://flask-jwt-extended.readthedocs.io/en/stable/automatic_user_loading/

# Register a callback function that takes whatever object is passed in as the
# identity when creating JWTs and converts it to a JSON serializable format.
@jwt.user_identity_loader
def user_identity_lookup(user):
    return user.id


# Register a callback function that loades a user from your database whenever
# a protected route is accessed. This should return any python object on a
# successful lookup, or None if the lookup failed for any reason (for example
# if the user has been deleted from the database).
@jwt.user_lookup_loader
def user_lookup_callback(_jwt_header, jwt_data):
    identity = jwt_data["sub"]
    return Account.query.filter_by(id=identity).one_or_none()
