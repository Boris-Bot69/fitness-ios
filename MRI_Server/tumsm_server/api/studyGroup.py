import json

from flask import Response, request, jsonify
from flask_jwt_extended import get_jwt_identity, jwt_required, current_user
from .views import blueprint
from .authorization import *

from ..studygroup.forms import (
    AddStudyGroup,
    AddStudyGroupPatients,
    AddStudyGroupTrainers,
    UpdateStudyGroup,
)
from ..studygroup.models import StudyGroup, StudyGroupPatients, StudyGroupTrainers


@blueprint.route("/studyGroup", methods=["POST"])
@jwt_required()
def add_study_group():
    """Endpoint for adding a study group"""
    if request.json is None:
        return Response({"400 Bad Request"}, status=400)
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    form = AddStudyGroup(obj=request.json, meta={"csrf": False})
    if form.validate_on_submit():
        study_group = StudyGroup.create(name=form.name.data)
        return {"studyGroup": study_group.id}
    return Response(json.dumps(form.errors), status=422, mimetype="application/json")


@blueprint.route("/studyGroup", methods=["PATCH"])
@jwt_required()
def update_study_group():
    """Endpoint for patching a study group"""
    if request.json is None or "id" not in request.json:
        return Response({"400 Bad Request"}, status=400)
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    study_group = StudyGroup.query.filter_by(id=request.json["id"]).first()
    if study_group is None:
        return Response("404 study group Not Found", status=404)
    form = UpdateStudyGroup(obj=request.json, meta={"csrf": False})
    if form.validate_on_submit():
        updatable = {"name": form.name.data}
        updated = {k: v for (k, v) in updatable.items() if k in request.json}
        study_group.update(**updated)
        return {"studyGroup": study_group.id}
    return Response(json.dumps(form.errors), status=422, mimetype="application/json")


@blueprint.route("/studyGroup", methods=["DELETE"])
@jwt_required()
def delete_study_group():
    """Endpoint for deleting a study group"""
    if request.args is None or "id" not in request.args:
        return Response({"400 Bad Request"}, status=400)
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    study_group = StudyGroup.query.filter_by(id=request.args.get("id")).first()
    if study_group is None:
        return Response("404 study group Not Found", status=404)
    study_group.delete()
    return {"studyGroup": study_group.id}


@blueprint.route("/studyGroup/overviews", methods=["GET"])
@jwt_required()
def study_group_overviews():
    """Endpoint for getting a list of all study groups"""
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    study_groups = StudyGroup.query.all()
    studyGroups = []
    for studygroup in study_groups:
        studyGroups.append({"id": studygroup.id, "name": studygroup.name})
    return jsonify(studyGroups)


@blueprint.route("/studyGroup/member", methods=["POST"])
@jwt_required()
def add_study_group_member():
    """Endpoint for adding a member to a study group"""
    if request.json is None:
        return Response({"400 Bad Request"}, status=400)
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    form = AddStudyGroupPatients(obj=request.json, meta={"csrf": False})
    if form.validate_on_submit():
        study_group_member = StudyGroupPatients.create(
            studyGroupId=form.studyGroupId.data, patientId=form.patientId.data
        )
        return {"studyGroupMember": study_group_member.id}
    return Response(json.dumps(form.errors), status=422, mimetype="application/json")


@blueprint.route("/studyGroup/member", methods=["DELETE"])
@jwt_required()
def delete_study_group_member():
    """Endpoint for removing a member from study group"""
    if request.args is None or "id" not in request.args:
        return Response({"400 Bad Request"}, status=400)
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    study_group_member = StudyGroupPatients.query.filter_by(
        id=request.args.get("id")
    ).first()
    if study_group_member is None:
        return Response("404 Study Group Member Not Found", status=404)
    study_group_member.delete()
    return {"studyGroupMember": study_group_member.id}


@blueprint.route("/studyGroup/trainer", methods=["POST"])
@jwt_required()
def add_study_group_trainer():
    """Endpoint for adding a trainer to a study group"""
    if request.json is None:
        return Response({"400 Bad Request"}, status=400)
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    form = AddStudyGroupTrainers(obj=request.json, meta={"csrf": False})
    if form.validate_on_submit():
        study_group_trainer = StudyGroupTrainers.create(
            studyGroupId=form.studyGroupId.data, trainerId=form.trainerId.data
        )
        return {"studyGroupTrainer": study_group_trainer.id}
    return Response(json.dumps(form.errors), status=422, mimetype="application/json")


@blueprint.route("/studyGroup/trainer", methods=["DELETE"])
@jwt_required()
def delete_study_group_trainer():
    """Endpoint for removing a trainer from study group"""
    if request.args is None or "id" not in request.args:
        return Response({"400 Bad Request"}, status=400)
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    study_group_trainer = StudyGroupTrainers.query.filter_by(
        id=request.args.get("id")
    ).first()
    if study_group_trainer is None:
        return Response("404 Study Group Trainer Not Found", status=404)
    study_group_trainer.delete()
    return {"studyGroupTrainer": study_group_trainer.id}
