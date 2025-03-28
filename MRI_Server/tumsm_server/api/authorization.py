"""Helper utilities specifically for api endpoints"""

from ..account.models import Account
from ..patient.models import Patient
from ..trainer.models import Trainer


def is_a_trainer(jwt_identity):
    """Checks if logged in user is a trainer"""
    return len(jwt_identity.trainers) > 0


def is_a_patient(jwt_identity):
    """Checks if logged in user is a patient"""
    return len(jwt_identity.patients) > 0


def is_patient(jwt_identity, patientId):
    """Checks if logged in user is a specific patient"""
    return Patient.query.filter_by(id=patientId).first().account.id == jwt_identity.id


def is_trainer(jwt_identity, trainerId):
    """Checks if logged in user is a specific trainer"""
    return Trainer.query.filter_by(id=trainerId).first().account.id == jwt_identity.id


def equals_account(jwt_identity, account):
    """Checks if logged in user is a specific user"""
    return account.id == jwt_identity.id
