import json

from flask import jsonify, Response, request
from flask_jwt_extended import get_jwt_identity, jwt_required, current_user
from .views import blueprint
from .authorization import *
from ..planning.forms import (
    AddPlannedWorkoutForm,
    UpdatePlannedWorkoutForm,
    ImportPlannedWorkoutsForm,
)
from ..planning.lib import import_planned_workouts
from ..planning.models import PlannedWorkout


@blueprint.route("/planning/import", methods=["POST"])
@jwt_required()
def add_training_plan_import():
    """Endpoint for importing multiple planned workouts for one patient (Not implemented yet)"""
    if request.json is None:
        return Response({"400 Bad Request"}, status=400)
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    form = ImportPlannedWorkoutsForm(obj=request.json, meta={"csrf": False})
    if form.validate_on_submit():
        patient = Patient.query.filter_by(id=form.patientId.data).first()
        success, plannedWorkoutIds = import_planned_workouts(
            patient, form.xlsxBase64.data
        )
        if success:
            return {"plannedWorkouts": plannedWorkoutIds}
        else:
            return Response(
                {"400 Bad Request - There was an error parsing the xlsx file"},
                status=400,
            )
    return Response(json.dumps(form.errors), status=422, mimetype="application/json")


@blueprint.route("/planning", methods=["POST"])
@jwt_required()
def add_training_plan():
    """Endpoint for adding a planned workout (Not implemented yet)"""
    if request.json is None:
        return Response({"400 Bad Request"}, status=400)
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    form = AddPlannedWorkoutForm(obj=request.json, meta={"csrf": False})
    if form.validate_on_submit():
        plannedWorkout = PlannedWorkout.create(
            patientId=form.patientId.data,
            plannedDate=form.plannedDate.data,
            type=form.type.data,
            maxHeartRate=form.maxHeartRate.data,
            minDuration=form.minDuration.data,
            minDistance=form.minDistance.data,
        )
        return {"plannedWorkout": plannedWorkout.id}
    return Response(json.dumps(form.errors), status=422, mimetype="application/json")


@blueprint.route("/planning", methods=["PATCH"])
@jwt_required()
def update_training_plan():
    """Endpoint for patching a planned workout (Not implemented yet)"""
    if request.json is None or "id" not in request.json:
        return Response({"400 Bad Request"}, status=400)
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    plannedWorkout = PlannedWorkout.query.filter_by(id=request.json["id"]).first()
    if plannedWorkout is None:
        return Response("404 Planned Workout Not Found", status=404)
    form = UpdatePlannedWorkoutForm(obj=request.json, meta={"csrf": False})
    if form.validate_on_submit():
        updatable = {
            "patientId": form.patientId.data,
            "plannedDate": form.plannedDate.data,
            "type": form.type.data,
            "maxHeartRate": form.maxHeartRate.data,
            "minDuration": form.minDuration.data,
            "minDistance": form.minDistance.data,
        }
        updated = {k: v for (k, v) in updatable.items() if k in request.json}
        plannedWorkout.update(**updated)
        return {"plannedWorkout": plannedWorkout.id}
    return Response(json.dumps(form.errors), status=422, mimetype="application/json")


@blueprint.route("/planning", methods=["DELETE"])
@jwt_required()
def delete_training_plan():
    """Endpoint for deleting a planned workout"""
    if request.args is None or "id" not in request.args:
        return Response({"400 Bad Request"}, status=400)
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    plannedWorkout = PlannedWorkout.query.filter_by(id=request.args.get("id")).first()
    if plannedWorkout is None:
        return Response("404 Planned Workout Not Found", status=404)
    plannedWorkout.delete()
    return {"plannedWorkout": plannedWorkout.id}
