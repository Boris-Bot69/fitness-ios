import json

from flask import Response, request
from flask_jwt_extended import jwt_required, current_user
from .views import blueprint
from .authorization import *

from ..trainer.forms import AddTrainerForm, UpdateTrainerForm


@blueprint.route("/trainer", methods=["POST"])
@jwt_required()
def add_trainer():
    """Endpoint for adding a trainer"""
    if request.json is None:
        return Response({"400 Bad Request"}, status=400)
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    form = AddTrainerForm(obj=request.json, meta={"csrf": False})
    if form.validate_on_submit():
        trainer = Trainer.create(accountId=form.accountId.data)
        return {"trainer": trainer.id}
    return Response(json.dumps(form.errors), status=422, mimetype="application/json")


@blueprint.route("/trainer", methods=["PATCH"])
@jwt_required()
def update_trainer():
    """Endpoint for patching a trainer"""
    # This method/endpoints doesn't really have a use case yet. This would only be required if we add some attributes
    # to trainers
    if request.json is None or "id" not in request.json:
        return Response({"400 Bad Request"}, status=400)
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    trainer = Trainer.query.filter_by(id=request.json["id"]).first()
    if trainer is None:
        return Response("404 Trainer Not Found", status=404)
    form = UpdateTrainerForm(obj=request.json, meta={"csrf": False})
    if form.validate_on_submit():
        updatable = {"accountId": form.accountId.data}
        updated = {k: v for (k, v) in updatable.items() if k in request.json}
        trainer.update(**updated)
        return {"trainer": trainer.id}
    return Response(json.dumps(form.errors), status=422, mimetype="application/json")


@blueprint.route("/trainer", methods=["DELETE"])
@jwt_required()
def delete_trainer():
    """Endpoint for deleting a trainer"""
    if request.args is None or "id" not in request.args:
        return Response({"400 Bad Request"}, status=400)
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    trainer = Trainer.query.filter_by(id=request.args.get("id")).first()
    if trainer is None:
        return Response("404 Trainer Not Found", status=404)
    trainer.delete()
    return {"trainer": trainer.id}
