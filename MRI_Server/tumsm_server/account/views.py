from flask import Blueprint, flash, redirect, render_template, request, url_for
from flask_login import login_required

from tumsm_server.account.forms import AddAccountForm
from tumsm_server.account.models import Account
from tumsm_server.utils import flash_errors

blueprint = Blueprint(
    "account", __name__, url_prefix="/account", static_folder="../static"
)


@blueprint.route("/")
@login_required
def overview():
    """List accounts."""
    accounts = Account.query
    return render_template(
        "accounts/overview.html",
        accounts=accounts,
        current_page="accounts",
    )


@blueprint.route("/add/", methods=["GET", "POST"])
@login_required
def add():
    """Add account."""
    form = AddAccountForm(request.form)
    if form.validate_on_submit():
        Account.create(
            username=form.username.data,
            email=form.email.data,
            password=form.password.data,
            birthday=form.birthday.data,
            firstName=form.firstName.data,
            lastName=form.lastName.data,
            active=True,
        )
        flash(
            f"{form.username.data} ({form.email.data}) has been added as an account",
            "success",
        )
        return redirect(url_for("account.overview"))
    else:
        flash_errors(form)
    return render_template(
        "accounts/add.html",
        form=form,
        current_page="accounts",
    )
