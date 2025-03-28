import json

from flask import jsonify, Response, request
from flask_jwt_extended import (
    jwt_required,
    current_user,
    create_access_token,
)
from .views import blueprint
from .authorization import *

from ..account.forms import AddAccountForm, UpdateAccountForm


@blueprint.route("/account/auth/verifyToken", methods=["GET"])
@jwt_required()
def check_validity_of_token():
    """Endpoint to check if token is valid"""
    return {"msg": "Token is valid"}


@blueprint.route("/account", methods=["POST"])
@jwt_required()
def add_account():
    """Endpoint for adding an account"""
    if request.json is None:
        return Response({"400 Bad Request"}, status=400)
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    form = AddAccountForm(obj=request.json, meta={"csrf": False})
    if form.validate_on_submit():
        account = Account.create(
            username=form.username.data,
            email=form.email.data,
            password=form.password.data,
            createdById=current_user.id,
            birthday=form.birthday.data,
            firstName=form.firstName.data,
            lastName=form.lastName.data,
            active=True,
        )
        return {"account": account.id}
    return Response(json.dumps(form.errors), status=422, mimetype="application/json")


@blueprint.route("/account", methods=["PATCH"])
@jwt_required()
def update_account():
    """Endpoint for patching an account"""
    if request.json is None or "id" not in request.json:
        return Response({"400 Bad Request"}, status=400)
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    account = Account.query.filter_by(id=request.json["id"]).first()
    if account is None:
        return Response("404 Account Not Found", status=404)
    form = UpdateAccountForm(obj=request.json, meta={"csrf": False})
    if form.validate_on_submit():
        updatable = {
            "username": form.username.data,
            "email": form.email.data,
            "password": form.password.data,
            "birthday": form.birthday.data,
            "firstName": form.firstName.data,
            "lastName": form.lastName.data,
            "active": form.active.data,
        }
        updated = {k: v for (k, v) in updatable.items() if k in request.json}
        account.update(**updated)
        return {"account": account.id}
    return Response(json.dumps(form.errors), status=422, mimetype="application/json")


@blueprint.route("/account", methods=["DELETE"])
@jwt_required()
def delete_account():
    """Endpoint for deleting an account"""
    if request.args is None or "id" not in request.args:
        return Response({"400 Bad Request"}, status=400)
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    account = Account.query.filter_by(id=request.args.get("id")).first()
    if account is None:
        return Response("404 Account Not Found", status=404)
    account.delete()
    return {"account": account.id}


@blueprint.route("/account/auth", methods=["POST"])
def auth():
    """Endpoint for authenticating as an account"""
    if request.json is None:
        return Response({"400 Bad Request"}, status=400)
    username = request.json.get("username", None)
    password = request.json.get("password", None)

    account = Account.query.filter_by(username=username).first()
    if not account:
        return {"msg": "Wrong username!"}, 401

    if not account.check_password(password):
        return {"msg": "Wrong password!"}, 401

    token = create_access_token(identity=account, expires_delta=False)
    auth_response = {
        "token": token,
    }

    if account.patients:
        auth_response["patientId"] = account.patients[0].id
    if account.trainers:
        auth_response["trainerId"] = account.trainers[0].id

    return auth_response


@blueprint.route("/account/overviews", methods=["GET"])
@jwt_required()
def account_overviews():
    """Endpoint for getting an overview over all accounts"""
    if not is_a_trainer(current_user):
        return Response("403 Forbidden", status=403)
    accounts = Account.query
    accountOverviews = []
    for account in accounts:
        accountOverviews.append(
            {
                "id": account.id,
                "username": account.username,
                "email": account.email,
                "birthday": account.birthday,
                "firstName": account.firstName,
                "lastName": account.lastName,
                "active": account.active,
                "createdAt": account.createdAt,
            }
        )
    return jsonify(accountOverviews)
