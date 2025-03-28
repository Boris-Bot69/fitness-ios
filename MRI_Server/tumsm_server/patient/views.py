"""Patient views."""
from flask import Blueprint, flash, redirect, render_template, request, url_for
from flask_login import login_required

from tumsm_server.utils import flash_errors
from .lib import create_patient_training_zones

from ..account.models import Account
from .forms import AddPatientForm, AddPatientTrainingZonesForm
from .models import Patient, PatientTrainingZones

blueprint = Blueprint(
    "patient", __name__, url_prefix="/patient", static_folder="../static"
)


@blueprint.route("/")
@login_required
def overview():
    """List patients."""
    patients = Patient.query
    training_zones = PatientTrainingZones.query
    return render_template(
        "patients/overview.html",
        patients=patients,
        training_zones=training_zones,
        current_page="patients",
    )


@blueprint.route("/add/", methods=["GET", "POST"])
@login_required
def add():
    """Add patient."""
    form = AddPatientForm(request.form)
    if form.validate_on_submit():
        Patient.create(
            accountId=form.accountId.data,
            treatmentStarted=form.treatmentStarted.data,
            treatmentFinished=form.treatmentFinished.data,
            treatmentGoal=form.treatmentGoal.data,
            height=form.height.data,
            weight=form.weight.data,
            gender=form.gender.data,
            comment=form.comment.data,
        )
        flash(
            f"A new patient has been created for account {form.accountId.data}",
            "success",
        )
        return redirect(url_for("patient.overview"))
    else:
        flash_errors(form)
    return render_template(
        "patients/add.html",
        form=form,
        current_page="patients",
    )


@blueprint.route("/trainingZones/add", methods=["GET", "POST"])
@login_required
def add_training_zone():
    """Add patient trainingzones."""
    form = AddPatientTrainingZonesForm(request.form)
    if form.validate_on_submit():
        training_zones = create_patient_training_zones(
            patientId=form.patientId.data,
            workoutType=form.workoutType.data,
            unit=form.unit.data,
            upper0Bound=form.upper0Bound.data,
            upper1Bound=form.upper1Bound.data,
            upper2Bound=form.upper2Bound.data,
            upper3Bound=form.upper3Bound.data,
        )
        flash(
            f"New training zones have been created for patient {form.patientId.data}",
            "success",
        )
        return redirect(url_for("patient.overview"))
    else:
        flash_errors(form)
        return render_template("patients/addTrainingZones.html", form=form)
