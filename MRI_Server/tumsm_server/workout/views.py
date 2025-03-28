"""Workout views."""
from flask import Blueprint, flash, redirect, render_template, request, url_for
from flask_login import login_required

from tumsm_server.utils import flash_errors

from .forms import AddWorkoutForm, AddWorkoutRating
from .lib import create_workout
from .models import Workout, WorkoutRating, Steps

blueprint = Blueprint(
    "workout", __name__, url_prefix="/workout", static_folder="../static"
)


@blueprint.route("/")
@login_required
def overview():
    """List workouts."""
    workouts = Workout.query
    workout_ratings = WorkoutRating.query
    steps = Steps.query
    return render_template(
        "workouts/overview.html",
        workouts=workouts,
        workoutRatings=workout_ratings,
        current_page="workouts",
    )


@blueprint.route("/add/", methods=["GET", "POST"])
@login_required
def add():
    """Add workout."""
    form = AddWorkoutForm(request.form)
    if form.validate_on_submit():
        workout = create_workout(form.healthJsonData.data, form.patientId.data)
        flash(
            f"A new workout has been for patient {form.patientId.data}",
            "success",
        )
        return redirect(url_for("workout.overview"))
    else:
        flash_errors(form)
    return render_template(
        "workouts/add.html",
        form=form,
        current_page="workouts",
    )


@blueprint.route("/rating/add/", methods=["GET", "POST"])
@login_required
def add_rating():
    """Add workout rating"""
    form = AddWorkoutRating(request.form)
    if form.validate_on_submit():
        WorkoutRating.create(
            workoutId=form.workoutId.data,
            rating=form.rating.data,
            intensity=form.intensity.data,
            comment=form.comment.data,
        )
        flash(
            f"A new workout rating has been for workout {form.workoutId.data}",
            "success",
        )
        return redirect(url_for("workout.overview"))
    else:
        flash_errors(form)
    return render_template(
        "workouts/addRating.html",
        form=form,
        current_page="workouts",
    )
