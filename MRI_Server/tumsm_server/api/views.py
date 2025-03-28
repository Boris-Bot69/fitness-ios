"""API endpoints."""

from flask import Blueprint, jsonify, request
from flask_jwt_extended import create_access_token, get_jwt_identity, jwt_required

from tumsm_server.patient.models import Patient

blueprint = Blueprint("api", __name__, url_prefix="/api/v1", static_folder="../static")
"""API v1 available at `/api/v1`."""
