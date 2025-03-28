import logging
import os

import flask
from flask import (
    Blueprint,
    flash,
    redirect,
    render_template,
    request,
    url_for,
    safe_join,
)
from flask_login import login_required

from tumsm_server.planning.forms import AddPlannedWorkoutForm
from tumsm_server.planning.lib import importCachePath
from tumsm_server.planning.models import PlannedWorkout
from tumsm_server.utils import flash_errors

blueprint = Blueprint(
    "planning", __name__, url_prefix="/planning", static_folder="../static"
)


@blueprint.route("/")
@login_required
def overview():
    """List planned workouts."""
    planned_workouts = PlannedWorkout.query
    return render_template(
        "planning/overview.html",
        planned_workouts=planned_workouts,
        current_page="planning",
    )


@blueprint.route("/template")
def downloadTemplate():
    """Download the static template for creating multiple planned workouts"""
    root_dir = os.path.dirname(os.getcwd())
    download_dir = safe_join(
        root_dir, "tumsm_server", "tumsm_server", "static", "import"
    )
    logging.info(f"Trying to download from '{download_dir}'")
    # Makes sure potential attackers cant get out of ./static/import/
    return flask.send_from_directory(download_dir, "import_template.xlsx")


@blueprint.route("/add", methods=["GET", "POST"])
@login_required
def add():
    """Add planned workout."""
    form = AddPlannedWorkoutForm(request.form)
    if form.validate_on_submit():
        PlannedWorkout.create(
            patientId=form.patientId.data,
            plannedDate=form.plannedDate.data,
            type=form.type.data,
            maxHeartRate=form.maxHeartRate.data,
            minDuration=form.minDuration.data,
            minDistance=form.minDistance.data,
        )
        flash(
            f"A planned workout for {form.plannedDate.data} has been added",
        )
        return redirect(url_for("planning.overview"))
    else:
        flash_errors(form)
    return render_template(
        "planning/add.html",
        form=form,
        current_page="planning",
    )
