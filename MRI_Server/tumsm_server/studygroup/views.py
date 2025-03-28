from flask import Blueprint, flash, redirect, render_template, request, url_for
from flask_login import login_required

from tumsm_server.studygroup.forms import (
    AddStudyGroup,
    AddStudyGroupPatients,
    AddStudyGroupTrainers,
)
from tumsm_server.studygroup.models import (
    StudyGroup,
    StudyGroupPatients,
    StudyGroupTrainers,
)
from tumsm_server.utils import flash_errors

from tumsm_server.studygroup.models import (
    StudyGroup,
    StudyGroupPatients,
    StudyGroupTrainers,
)
from tumsm_server.studygroup.forms import (
    AddStudyGroup,
    AddStudyGroupPatients,
    AddStudyGroupTrainers,
)

blueprint = Blueprint(
    "studygroup", __name__, url_prefix="/studygroup", static_folder="../static"
)


@blueprint.route("/")
@login_required
def overview():
    """List studygroups"""
    studygroups = StudyGroup.query
    studygroup_members = StudyGroupPatients.query
    studygroup_trainers = StudyGroupTrainers.query
    return render_template(
        "studygroup/overview.html",
        studygroups=studygroups,
        studygroup_members=studygroup_members,
        studygroup_trainers=studygroup_trainers,
        current_page="studygroups",
    )


@blueprint.route("/add/", methods=["GET", "POST"])
@login_required
def add():
    """Add studygroup."""
    form = AddStudyGroup(request.form)
    if form.validate_on_submit():
        studygroup = StudyGroup.create(name=form.name.data)
        flash(
            f"{form.name.data} has been added as an studygroup",
            "success",
        )
        return redirect(url_for("studygroup.overview"))
    else:
        flash_errors(form)
    return render_template(
        "studygroup/add.html",
        form=form,
        current_page="studygroups",
    )


@blueprint.route("/member/add/", methods=["GET", "POST"])
@login_required
def add_patient():
    """Add patient to studygroup"""
    form = AddStudyGroupPatients(request.form)
    if form.validate_on_submit():
        studygroup_patient = StudyGroupPatients.create(
            studyGroupId=form.studyGroupId.data, patientId=form.patientId.data
        )
        flash(
            f"patient {form.patientId.data} has been added to studygroup {form.studyGroupId.data}",
            "success",
        )
        return redirect(url_for("studygroup.overview"))
    else:
        flash_errors(form)
    return render_template(
        "studygroup/addMember.html",
        form=form,
        current_page="studygroups",
    )


@blueprint.route("/trainer/add/", methods=["GET", "POST"])
@login_required
def add_trainer():
    """Add trainer to studygroup."""
    form = AddStudyGroupTrainers(request.form)
    if form.validate_on_submit():
        studygroup_trainer = StudyGroupTrainers.create(
            studyGroupId=form.studyGroupId.data, trainerId=form.trainerId.data
        )
        flash(
            f"trainer {form.trainerId.data} has been added to studygroup {form.studyGroupId.data}",
            "success",
        )
        return redirect(url_for("studygroup.overview"))
    else:
        flash_errors(form)
    return render_template(
        "studygroup/addTrainer.html",
        form=form,
        current_page="studygroups",
    )
