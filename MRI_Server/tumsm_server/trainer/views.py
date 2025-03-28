"""User views."""
from flask import Blueprint, flash, redirect, render_template, request, url_for
from flask_login import login_required

from tumsm_server.utils import flash_errors

from .forms import AddTrainerForm
from .models import Trainer

blueprint = Blueprint(
    "trainer", __name__, url_prefix="/trainer", static_folder="../static"
)


@blueprint.route("/")
@login_required
def overview():
    """List trainers."""
    trainers = Trainer.query
    return render_template(
        "trainers/overview.html",
        trainers=trainers,
        current_page="trainers",
    )


@blueprint.route("/add/", methods=["GET", "POST"])
@login_required
def add():
    """Add Trainer."""
    form = AddTrainerForm(request.form)
    if form.validate_on_submit():
        Trainer.create(accountId=form.accountId.data)
        flash(
            f"A new trainer has been for account {form.accountId.data}",
            "success",
        )
        return redirect(url_for("trainer.overview"))
    else:
        flash_errors(form)
    return render_template(
        "trainers/add.html",
        form=form,
        current_page="trainers",
    )
