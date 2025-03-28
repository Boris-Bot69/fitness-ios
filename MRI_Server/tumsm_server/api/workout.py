import json

from flask import jsonify, Response, request
from flask_jwt_extended import jwt_required, current_user

from sqlalchemy import extract

from ..patient.lib import training_progress
from ..planning.lib import runningWorkoutType, cyclingWorkoutType
from ..planning.models import PlannedWorkout
from ..utils import parse_date, force_to_float, force_to_int
from ..workout.forms import (
    AddWorkoutForm,
    AddWorkoutRating,
    UpdateWorkoutRating,
    AddStepsForm,
)
from tumsm_server.workout.models import Workout, WorkoutRating, Steps

from ..workout.lib import create_workout, get_combined_profile
from .authorization import *
from ..utils import log_enter_and_exit
from .views import blueprint


@blueprint.route("/workout/steps", methods=["POST"])
@jwt_required()
def add_steps():
    """Endpoint for adding steps a patient did on a given date"""
    account = current_user

    if len(account.patients) == 0:
        return Response({"404 No patient found for this account"}, status=404)

    patient = account.patients[0]

    if (
        request.json is None
        or request.json["date"] is None
        or request.json["amount"] is None
    ):
        return Response({"400 Bad Request"}, status=400)

    request.json["patientId"] = patient.id
    form = AddStepsForm(obj=request.json, meta={"csrf": False})
    if form.validate_on_submit():
        steps = Steps.create(
            patientId=patient.id, date=form.date.data, amount=form.amount.data
        )
        return {"steps": steps.id}
    return Response(json.dumps(form.errors), status=422, mimetype="application/json")


@blueprint.route("/workout", methods=["POST", "PATCH"])
@jwt_required()
def add_workout():
    """Endpoint for adding a workout to a patient"""
    # Returns existing workout when posting a workout with a know appleUUID (or when patching)
    account = current_user

    if len(account.patients) == 0:
        return Response({"404 No patient found for this account"}, status=404)

    patient = account.patients[0]

    if request.json is None:
        return Response({"400 Bad Request"}, status=400)

    request.json["patientId"] = patient.id
    form = AddWorkoutForm(obj=request.json, meta={"csrf": False})
    if form.validate_on_submit():
        workout_json = request.json.get("healthJsonData")
        isPatch = request.method == "PATCH"
        workout = create_workout(workout_json, patient.id, patch=isPatch)
        if workout is None:
            return Response(
                {
                    "400 Bad Request - There was an error parsing the healthKit data, Or there was no workout to patch"
                },
                status=400,
            )
        return {"workout": workout.id}
    return Response(json.dumps(form.errors), status=422, mimetype="application/json")


@blueprint.route("/workout/raw", methods=["GET"])
@jwt_required()
def get_workout_raw():
    """Endpoint for getting the raw data of a workout"""
    if request.args is None or "id" not in request.args:
        return Response({"400 Bad Request"}, status=400)
    workout = Workout.query.filter_by(id=request.args.get("id")).first()
    if workout is None:
        return Response("404 Workout Not Found", status=404)
    rawWorkout = workout.rawJson[0]
    if rawWorkout is None:
        return Response("404 Raw Workout Not Found", status=404)
    return {
        "workoutId": workout.id,
        "rawJson": json.loads(rawWorkout.healthKitJson.decode()),
    }


@blueprint.route("/workout", methods=["GET"])
@jwt_required()
def get_workout():
    """Endpoint for getting the data of a workout"""
    requested_workoutId = request.args.get("id")
    requested_workout_uuid = request.args.get("appleUUID")
    sample_rate = request.args.get("sampleRate")
    if (
        (requested_workoutId is None and requested_workout_uuid is None)
        or (requested_workoutId is not None and requested_workout_uuid is not None)
        or sample_rate is None
    ):
        return Response({"400 Bad Request"}, status=400)
    workout = None
    if requested_workoutId is not None:
        workout = Workout.query.filter_by(id=requested_workoutId).first()
    if requested_workout_uuid is not None:
        workout = Workout.query.filter_by(appleUUID=requested_workout_uuid).first()
    if workout is None:
        return Response("404 Workout not found", status=404)
    else:
        if not equals_account(
            current_user, workout.patient.account
        ) and not is_a_trainer(current_user):
            return Response("403 Forbidden", status=403)
        sample_rate = request.args.get("sampleRate")
        if not isinstance(sample_rate, int):
            sample_rate = force_to_int(sample_rate)
        combined_profile = get_combined_profile(sample_rate, workout=workout)
        patient = Patient.query.filter_by(id=workout.patientId).first()
        return {
            "id": workout.id,
            "rating": workout.rating(),
            "intensity": workout.intensity(),
            "comment": workout.comment(),
            "distance": force_to_float(workout.distance),
            "duration": force_to_float(workout.duration),
            "endTime": workout.endTime,
            "kcal": force_to_int(workout.kcal),
            "kilometerPace": workout.kilometerPace_data,
            "startTime": workout.startTime,
            "terrainDown": force_to_float(workout.terrainDown),
            "terrainUp": force_to_float(workout.terrainUp),
            "heartRateAvg": force_to_float(workout.heartRateAvg),
            "heartRateMin": force_to_float(workout.heartRateMin),
            "heartRateMax": force_to_float(workout.heartRateMax),
            "speedAvg": force_to_float(workout.speedAvg),
            "speedMin": force_to_float(workout.speedMin),
            "speedMax": force_to_float(workout.speedMax),
            "paceMin": workout.paceMin,
            "paceMax": workout.paceMax,
            "trainingZones": workout.trainingZones_data,
            "type": force_to_int(workout.type),
            "combinedProfiles": combined_profile,
        }


@blueprint.route("/workout", methods=["DELETE"])
@jwt_required()
def delete_workout():
    """Endpoint for deleting a workout"""
    if request.args is None or "id" not in request.args:
        return Response({"400 Bad Request"}, status=400)
    workout = Workout.query.filter_by(id=request.args.get("id")).first()
    if workout is None:
        return Response("404 Workout Not Found", status=404)
    if not is_a_trainer(current_user) and not is_patient(
        current_user, workout.patientId
    ):
        return Response("403 Forbidden", status=403)
    workout.delete()
    return {"workout": workout.id}


@blueprint.route("/workout/overviews", methods=["GET"])
@jwt_required()
@log_enter_and_exit
def workouts():
    """Endpoint for getting an overview over all workouts of a patient in a given time frame"""
    if request.args is None:
        return Response({"400 Bad Request"}, status=400)

    from_date = request.args.get("fromDate")
    to_date = request.args.get("toDate")
    patientId = request.args.get("patientId")

    account = current_user
    if is_a_patient(current_user) and patientId is None:
        patientId = account.patients[0].id

    from_date_p = parse_date(from_date) if from_date is not None else None
    to_date_p = parse_date(to_date) if to_date is not None else None

    if patientId is None:
        return Response({"400 Bad Request"}, status=400)
    found_workouts = Workout.query.filter_by(patientId=patientId)
    found_steps = Steps.query.filter_by(patientId=patientId)
    if from_date_p is not None and to_date_p is not None:
        found_workouts = found_workouts.filter(Workout.startTime >= from_date_p).filter(
            Workout.startTime < to_date_p
        )
        found_steps = found_steps.filter(Steps.date >= from_date_p).filter(
            Steps.date < to_date_p
        )
    found_workouts = found_workouts.all()
    found_steps = found_steps.all()

    workouts = []
    duration_sum_running = 0
    duration_sum_cycling = 0
    distance_sum_running = 0
    distance_sum_cycling = 0
    heartRate_segments_running = {
        "total": 0,
        "zone0HeartRate": 0,
        "zone1HeartRate": 0,
        "zone2HeartRate": 0,
        "zone3HeartRate": 0,
        "zone4HeartRate": 0,
    }
    heartRate_segments_cycling = {
        "total": 0,
        "zone0HeartRate": 0,
        "zone1HeartRate": 0,
        "zone2HeartRate": 0,
        "zone3HeartRate": 0,
        "zone4HeartRate": 0,
    }
    for workout in found_workouts:
        training_zones = workout.trainingZones_data
        if workout.type == runningWorkoutType:
            duration_sum_running += workout.duration
            distance_sum_running += workout.distance
            if training_zones != {} and training_zones["heartRate"] is not None:
                heartRate_segments_running["total"] += training_zones["heartRate"][
                    "total"
                ]
                heartRate_segments_running["zone0HeartRate"] += training_zones[
                    "heartRate"
                ]["zone0"]
                heartRate_segments_running["zone1HeartRate"] += training_zones[
                    "heartRate"
                ]["zone1"]
                heartRate_segments_running["zone2HeartRate"] += training_zones[
                    "heartRate"
                ]["zone2"]
                heartRate_segments_running["zone3HeartRate"] += training_zones[
                    "heartRate"
                ]["zone3"]
                heartRate_segments_running["zone4HeartRate"] += training_zones[
                    "heartRate"
                ]["zone4"]
        elif workout.type == cyclingWorkoutType:
            duration_sum_cycling += workout.duration
            distance_sum_cycling += workout.distance
            if training_zones != {} and training_zones["heartRate"] is not None:
                heartRate_segments_cycling["total"] += training_zones["heartRate"][
                    "total"
                ]
                heartRate_segments_cycling["zone0HeartRate"] += training_zones[
                    "heartRate"
                ]["zone0"]
                heartRate_segments_cycling["zone1HeartRate"] += training_zones[
                    "heartRate"
                ]["zone1"]
                heartRate_segments_cycling["zone2HeartRate"] += training_zones[
                    "heartRate"
                ]["zone2"]
                heartRate_segments_cycling["zone3HeartRate"] += training_zones[
                    "heartRate"
                ]["zone3"]
                heartRate_segments_cycling["zone4HeartRate"] += training_zones[
                    "heartRate"
                ]["zone4"]
        workouts.append(
            {
                "workoutId": workout.id,
                "type": force_to_int(workout.type),
                "appleUUID": workout.appleUUID,
                "startTime": workout.startTime,
                "rating": workout.rating(),
                "comment": workout.comment(),
                "intensity": workout.intensity(),
                "calories": workout.kcal,
                "distance": force_to_float(workout.distance),
                "duration": force_to_float(workout.duration),
                "mainHeartRateSegment": force_to_int(workout.mainHeartRate_segment()),
            }
        )
    patient = Patient.query.filter_by(id=patientId).first()
    if patient is None:
        return Response("404 Patient Not Found", status=404)
    name = patient.account.full_name
    treatment_goal = patient.treatmentGoal
    if patient.study_group is None:
        study_group = None
    else:
        study_group = patient.study_group.name
    steps = [x.asJson for x in found_steps]
    plannedWorkouts = [
        p.asJson
        for p in patient.plannedWorkouts
        if (from_date_p is None or from_date_p.date() <= p.plannedDate)
        and (to_date_p is None or to_date_p.date() >= p.plannedDate)
    ]

    trainingProgressRunning = training_progress(patient, from_date_p, to_date_p, runningWorkoutType)
    trainingProgressCycling = training_progress(patient, from_date_p, to_date_p, cyclingWorkoutType)

    return {
        "name": name,
        "studyGroup": study_group,
        "treatmentGoal": treatment_goal,
        "workouts": workouts,
        "runningOverview": {
            "trainingsDue": force_to_int(trainingProgressRunning["completed"]),
            "trainingsDone": force_to_int(trainingProgressRunning["total"]),
            "duration": force_to_float(duration_sum_running),
            "distance": force_to_float(distance_sum_running),
            "heartRateTrainingZones": heartRate_segments_running,
        },
        "cyclingOverview": {
            "trainingsDue": force_to_int(trainingProgressCycling["completed"]),
            "trainingsDone": force_to_int(trainingProgressCycling["total"]),
            "duration": force_to_float(duration_sum_cycling),
            "distance": force_to_float(distance_sum_cycling),
            "heartRateTrainingZones": heartRate_segments_cycling,
        },
        "steps": steps,
        "plannedWorkouts": plannedWorkouts,
    }


@blueprint.route("workout/rating", methods=["POST"])
@jwt_required()
def add_workout_rating():
    """Endpoint for adding a workout rating to a workout"""
    if request.json is None or "workoutId" not in request.json:
        return Response({"400 Bad Request"}, status=400)
    workout = Workout.query.filter_by(id=request.json["workoutId"]).first()
    if workout is None:
        return Response("404 Workout Not Found", status=404)
    if not is_patient(current_user, workout.patientId):
        return Response("403 Forbidden", status=403)
    form = AddWorkoutRating(obj=request.json, meta={"csrf": False})
    if form.validate_on_submit():
        rating = WorkoutRating.create(
            workoutId=form.workoutId.data,
            rating=form.rating.data,
            intensity=form.intensity.data,
            comment=form.comment.data,
        )
        return {"rating": rating.id}
    return Response(json.dumps(form.errors), status=422, mimetype="application/json")


@blueprint.route("workout/rating", methods=["PATCH"])
@jwt_required()
def update_workout_rating():
    """Endpoint for updating a workout rating"""
    if request.json is None or "id" not in request.json:
        return Response({"400 Bad Request"}, status=400)
    rating = WorkoutRating.query.filter_by(id=request.json["id"]).first()
    if rating is None:
        return Response("404 Workout Rating Not Found", status=404)
    workout = Workout.query.filter_by(id=rating.workoutId).first()
    if workout is None:
        return Response("404 Workout Not Found", status=404)
    if not is_patient(current_user, workout.patientId):
        return Response("403 Forbidden", status=403)
    form = UpdateWorkoutRating(obj=request.json, meta={"csrf": False})
    if form.validate_on_submit():
        updatable = {
            "rating": form.rating.data,
            "intensity": form.intensity.data,
            "comment": form.comment.data,
        }
        updated = {k: v for (k, v) in updatable.items() if k in request.json}
        rating.update(**updated)
        return {"rating": rating.id}

    return Response(json.dumps(form.errors), status=422, mimetype="application/json")


@blueprint.route("workout/rating", methods=["DELETE"])
@jwt_required()
def delete_workout_rating():
    """Endpoint for deleting a workout rating"""
    if request.args is None or "id" not in request.args:
        return Response({"400 Bad Request"}, status=400)
    rating = WorkoutRating.query.filter_by(id=request.args.get("id")).first()
    if rating is None:
        return Response("404 Workout Rating Not Found", status=404)
    workout = Workout.query.filter_by(id=rating.workoutId).first()
    if workout is None:
        return Response("404 Workout Not Found", status=404)
    if not is_patient(current_user, workout.patientId):
        return Response("403 Forbidden", status=403)
    rating.delete()
    return {"rating": rating.id}
