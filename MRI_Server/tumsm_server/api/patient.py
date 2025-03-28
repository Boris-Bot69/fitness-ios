import json
from flask_jwt_extended import jwt_required, current_user
from flask import jsonify, Response, request

from tumsm_server.patient.models import Patient, PatientTrainingZones

from .authorization import is_a_trainer, equals_account, is_patient
from .views import blueprint
import tumsm_server.patient.lib as lib

from ..patient.forms import (
    AddPatientForm,
    UpdatePatientForm,
    AddPatientTrainingZonesForm,
)
from ..utils import parse_date, force_to_float
from ..planning.lib import runningWorkoutType, cyclingWorkoutType


@blueprint.route("/patient", methods=["POST"])
@jwt_required()
def add_patient():
    """Endpoint for adding a patient"""
    if request.json is None:
        return Response({"400 Bad Request"}, status=400)
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    form = AddPatientForm(obj=request.json, meta={"csrf": False})
    if form.validate_on_submit():
        patient = Patient.create(
            accountId=form.accountId.data,
            treatmentStarted=form.treatmentStarted.data,
            treatmentGoal=form.treatmentGoal.data,
            treatmentFinished=form.treatmentFinished.data,
            height=form.height.data,
            weight=form.weight.data,
            gender=form.gender.data,
            comment=form.comment.data,
        )
        return {"patient": patient.id}
    return Response(json.dumps(form.errors), status=422, mimetype="application/json")


@blueprint.route("/patient", methods=["GET"])
@jwt_required()
def get_patient():
    if request.args is None or request.args.get("id") is None:
        return Response({"400 Bad Request"}, status=400)
    patientId = request.args.get("id")
    if not is_a_trainer(current_user) and not is_patient(current_user, patientId):
        return Response({"403 Forbidden"}, status=403)
    patient = Patient.query.filter_by(id=patientId).first()
    if patient is None:
        return Response({"404 Patient Not Found"}, status=404)
    return {
        "id": patient.id,
        "accountId": patient.accountId,
        "treatmentStarted": patient.treatmentStarted,
        "treatmentFinished": patient.treatmentFinished,
        "treatmentGoal": patient.treatmentGoal,
        "height": patient.height,
        "weight": patient.weight,
        "gender": patient.gender,
        "comment": patient.comment,
    }


@blueprint.route("/patient/export", methods=["GET"])
@jwt_required()
def export_data():
    if request.args is None or request.args.get("patientIds") is None:
        return Response({"400 Bad Request"}, status=400)
    patientIds = request.args.getlist("patientIds")
    fromDate = request.args.get("fromDate")
    toDate = request.args.get("toDate")
    if fromDate is not None:
        fromDate = parse_date(fromDate)
    if toDate is not None:
        toDate = parse_date(toDate)
    patientDumps = []
    selectedPatients = Patient.query.filter(Patient.id.in_(patientIds)).all()
    for patient in selectedPatients:
        patientDumps.append(
            {
                "patientId": patient.id,
                "overview": lib.get_patient_xlsx(patient, fromDate, toDate),
            }
        )
    return jsonify(patientDumps)


@blueprint.route("/patient/trainingZones", methods=["GET"])
@jwt_required()
def get_patient_training_zones():
    """Endpoint for getting the current training zones of a patient"""
    if request.args is None:
        return Response({"400 Bad Request"}, status=400)
    patientId = request.args.get("patientId")
    patient = Patient.query.filter_by(id=patientId).first()
    if patient is None:
        return Response({"404 patient not found"}, status=404)
    if not is_a_trainer(current_user):
        if not equals_account(current_user, patient.account):
            return Response("403 Forbidden", status=403)
    return {"trainingZones": patient.training_zone_segments_json}


@blueprint.route("/patient/trainingZones", methods=["POST"])
@jwt_required()
def add_patient_training_zones():
    """Endpoint for adding new training zones for a patient"""
    if request.json is None:
        return Response({"400 Bad Request"}, status=400)
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    form = AddPatientTrainingZonesForm(obj=request.json, meta={"csrf": False})
    if form.validate_on_submit():
        training_zones = lib.create_patient_training_zones(
            patientId=form.patientId.data,
            workoutType=form.workoutType.data,
            unit=form.unit.data,
            upper0Bound=form.upper0Bound.data,
            upper1Bound=form.upper1Bound.data,
            upper2Bound=form.upper2Bound.data,
            upper3Bound=form.upper3Bound.data,
        )
        return {"patientTrainingZones": training_zones.id}
    return Response(json.dumps(form.errors), status=422, mimetype="application/json")


@blueprint.route("/patient/trainingZones", methods=["DELETE"])
@jwt_required()
def delete_patient_training_zones():
    """Endpoint for deprecating training zones"""
    if request.args is None or "id" not in request.args:
        return Response({"400 Bad Request"}, status=400)
    id = request.args.get("id")
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    trainingZone = PatientTrainingZones.query.filter_by(id=id).first()
    if trainingZone is None:
        return Response({"404 Bad Request"}, status=404)
    trainingZone.update({"active": False})
    return {"trainingZone": trainingZone.id}


@blueprint.route("/patient", methods=["PATCH"])
@jwt_required()
def update_patient():
    """Endpoint for patching a patient"""
    if request.json is None or "id" not in request.json:
        return Response({"400 Bad Request"}, status=400)
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    patient = Patient.query.filter_by(id=request.json["id"]).first()
    if patient is None:
        return Response("404 Patient Not Found", status=404)
    form = UpdatePatientForm(obj=request.json, meta={"csrf": False})
    if form.validate_on_submit():
        updatable = {
            "accountId": form.accountId.data,
            "treatmentStarted": form.treatmentStarted.data,
            "treatmentGoal": form.treatmentGoal.data,
            "treatmentFinished": form.treatmentFinished.data,
            "height": form.height.data,
            "weight": form.weight.data,
            "gender": form.gender.data,
            "comment": form.comment.data,
        }
        updated = {k: v for (k, v) in updatable.items() if k in request.json}
        patient.update(**updated)
        return {"patient": patient.id}
    return Response(json.dumps(form.errors), status=422, mimetype="application/json")


@blueprint.route("/patient", methods=["DELETE"])
@jwt_required()
def delete_patient():
    """Endpoint for deleting a patient"""
    if request.args is None or "id" not in request.args:
        return Response({"400 Bad Request"}, status=400)
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    patient = Patient.query.filter_by(id=request.args.get("id")).first()
    if patient is None:
        return Response("404 Patient Not Found", status=404)
    patient.delete()
    return {"patient": patient.id}


@blueprint.route("/patient/overviews", methods=["GET"])
@jwt_required()
def patients():
    """Endpoint for getting an overview over all patients"""
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    if request.args is None:
        fromDate = None
        toDate = None
    else:
        fromDate = request.args.get("fromDate")
        toDate = request.args.get("toDate")
        try:
            if fromDate is not None:
                fromDate = parse_date(fromDate)
            if toDate is not None:
                toDate = parse_date(toDate)
        except ValueError:
            return Response("400 Bad Request - Wrong date format", status=403)
    patient_overview = []
    for patient in Patient.query.all():
        heartRateTrainingZoneCycling = patient.active_training_zone(
            "HEARTRATE", cyclingWorkoutType
        )
        speedTrainingZoneCycling = patient.active_training_zone(
            "SPEED", cyclingWorkoutType
        )
        heartRateTrainingZoneRunning = patient.active_training_zone(
            "HEARTRATE", runningWorkoutType
        )
        speedTrainingZoneRunning = patient.active_training_zone(
            "SPEED", runningWorkoutType
        )
        trainingZoneIntervals = [
            x
            for x in [
                heartRateTrainingZoneCycling,
                speedTrainingZoneCycling,
                heartRateTrainingZoneRunning,
                speedTrainingZoneRunning,
            ]
            if x is not None
        ]
        patient_overview.append(
            {
                "id": patient.id,
                "accountId": patient.accountId,
                "firstName": patient.account.firstName,
                "lastName": patient.account.lastName,
                "birthday": patient.account.birthday,
                "treatmentStarted": patient.treatmentStarted,
                "treatmentFinished": patient.treatmentFinished,
                "weekProgress": lib.week_progress(patient),
                "lastTraining": lib.last_training(patient),
                "ratings": lib.rating_overview(patient, fromDate, toDate),
                "trainingProgress": lib.training_progress(patient, fromDate, toDate),
                "studyGroups": lib.get_study_group_array(patient.studygroups),
                "heartRateProfileRunning": lib.get_heartrate_profile(
                    patient, fromDate, toDate, runningWorkoutType
                ),
                "heartRateProfileCycling": lib.get_heartrate_profile(
                    patient, fromDate, toDate, cyclingWorkoutType
                ),
                "active": patient.account.active,
                "totalHours": lib.get_total_workout_hours(patient, fromDate, toDate),
                "height": patient.height,
                "weight": patient.weight,
                "gender": patient.gender,
                "comment": patient.comment,
                "email": patient.account.email,
                "username": patient.account.username,
                "treatmentGoal": patient.treatmentGoal,
                "trainingZoneIntervals": trainingZoneIntervals,
            }
        )
    return jsonify(patient_overview)
