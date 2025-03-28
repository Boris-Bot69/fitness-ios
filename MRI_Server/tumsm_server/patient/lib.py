import base64
import datetime
import math

import xlsxwriter

from tumsm_server.patient.models import PatientTrainingZones
from tumsm_server.utils import (
    format_date,
    workout_type_description,
    log_enter_and_exit,
    force_to_int,
    force_to_date,
)
from tumsm_server.workout.models import Workout
from threading import Lock
from pathlib import Path
import tumsm_server.workout.models as WorkoutModels

export_lock = Lock()
exportCachePath = "./export/"


@log_enter_and_exit
def create_patient_training_zones(
    patientId, workoutType, unit, upper0Bound, upper1Bound, upper2Bound, upper3Bound
):
    """Create Patient Training Zones & Set potential old ones to inactive"""
    old_patient_training_zones = (
        PatientTrainingZones.query.filter_by(patientId=patientId)
        .filter_by(workoutType=workoutType)
        .filter_by(unit=unit)
        .all()
    )
    for old_training_zones in old_patient_training_zones:
        old_training_zones.update(active=False)
    training_zones = PatientTrainingZones.create(
        patientId=patientId,
        active=True,
        workoutType=workoutType,
        unit=unit,
        upper0Bound=upper0Bound,
        upper1Bound=upper1Bound,
        upper2Bound=upper2Bound,
        upper3Bound=upper3Bound,
    )
    return training_zones


@log_enter_and_exit
def week_progress(patient):
    """Return how many workouts were planned & completed in this calendar week"""
    timeDeltaTotal = patient.treatmentFinished - patient.treatmentStarted
    if patient.treatmentStarted <= datetime.date.today():
        timeDeltaCompleted = datetime.date.today() - patient.treatmentStarted
    else:
        timeDeltaCompleted = 0
    return {
        "completed": math.ceil(timeDeltaCompleted.days / 7),
        "total": math.ceil(timeDeltaTotal.days / 7),
    }


@log_enter_and_exit
def last_training(patient):
    """Return the start time of the latest training uploaded by a patient"""
    found_workouts = (
        Workout.query.filter_by(patientId=patient.id)
        .order_by(Workout.startTime.desc())
        .first()
    )
    if found_workouts is None:
        return None
    return found_workouts.startTime


@log_enter_and_exit
def rating_overview(patient, fromDate, toDate):
    """Return how many workouts were rated not at all, bad, medium or good by a patient in a given time frame"""
    unrated_count = 0
    bad_count = 0
    medium_count = 0
    good_count = 0
    for workout in patient.workouts:
        if (fromDate is not None and fromDate > workout.startTime) or (
            toDate is not None and workout.startTime > toDate
        ):
            continue
        rating = workout.rating()
        if rating == 1:
            bad_count += 1
        elif rating == 2:
            medium_count += 1
        elif rating == 3:
            good_count += 1
        else:
            unrated_count += 1
    return {
        "unrated": unrated_count,
        "bad": bad_count,
        "medium": medium_count,
        "good": good_count,
    }


@log_enter_and_exit
def training_progress(patient, fromDate, toDate, type=None):
    """Return how many workouts were planned & completed in a given time frame"""
    total = 0
    complete = 0
    for plannedWorkout in patient.plannedWorkouts:
        if (
            (fromDate is None or force_to_date(fromDate) <= plannedWorkout.plannedDate)
            and (toDate is None or force_to_date(toDate) >= plannedWorkout.plannedDate)
            and (plannedWorkout.plannedDate <= datetime.date.today())
            and (type is None or plannedWorkout.type == type)
        ):
            total += 1
            if plannedWorkout.complete:
                complete += 1
    return {"completed": complete, "total": total}


@log_enter_and_exit
def get_heartrate_profile(patient, fromDate, toDate, workoutType):
    """Return how many samples were in the heart rate zones of a patient in a given time frame"""
    zone0 = 0
    zone1 = 0
    zone2 = 0
    zone3 = 0
    zone4 = 0
    for workout in patient.workouts:
        if (
            (fromDate is not None and fromDate > workout.startTime)
            or (toDate is not None and workout.startTime > toDate)
            or workout.type != workoutType
        ):
            continue
        training_zones = workout.trainingZones_data
        if training_zones != {} and training_zones["heartRate"] is not None:
            zone0 += training_zones["heartRate"]["zone0"]
            zone1 += training_zones["heartRate"]["zone1"]
            zone2 += training_zones["heartRate"]["zone2"]
            zone3 += training_zones["heartRate"]["zone3"]
            zone4 += training_zones["heartRate"]["zone4"]
    return {
        "zone0": zone0,
        "zone1": zone1,
        "zone2": zone2,
        "zone3": zone3,
        "zone4": zone4,
    }


def get_study_group_array(study_groups):
    """Returns all study group names"""
    return [s.studygroup.name for s in study_groups]


@log_enter_and_exit
def get_total_workout_hours(patient, fromDate, toDate):
    """Returns the sum (as float) of all workout durations in hours"""
    durationSum = 0  # in seconds
    for workout in patient.workouts:
        if (fromDate is not None and fromDate > workout.startTime) or (
            toDate is not None and workout.startTime > toDate
        ):
            continue
        durationSum += workout.duration
    return float(durationSum / 60 / 60)


def format_for_export(data):
    if data is None:
        return ""
    if isinstance(data, float):
        return round(data, 3)
    if isinstance(data, int):
        return data
    return str(data)


@log_enter_and_exit
def get_patient_xlsx(patient, fromDate, toDate):
    workouts = WorkoutModels.Workout.query.filter_by(patientId=patient.id)
    Path(exportCachePath).mkdir(exist_ok=True)
    fileName = exportCachePath + str(patient.id) + ".xlsx"
    if fromDate is not None:
        workouts = workouts.filter(WorkoutModels.Workout.startTime >= fromDate)
    if toDate is not None:
        workouts = workouts.filter(WorkoutModels.Workout.startTime < toDate)
    workouts = workouts.all()
    with export_lock:
        workbook = xlsxwriter.Workbook(fileName)
        overview_worksheet = add_patient_overview_table(workbook, patient, workouts)
        for x in range(len(workouts)):
            workout = workouts[x]
            workout_worksheet = add_workout_table(workbook, workout)
            url_cell_string = format_for_export(workout.startTime)
            overview_worksheet.write_url(
                x + 1,
                0,
                "internal:'" + workout_worksheet.name + "'!A1",
                string=url_cell_string,
            )
        workbook.close()
        with open(fileName, "rb") as file:
            return base64.b64encode(file.read()).decode("UTF-8")


def add_line_to_worksheet(worksheet, lineDataDict, headers, lastWrittenRow):
    """Adds a data to a subtable according to the columns of the headers"""

    row = lastWrittenRow + 1
    for x in range(len(headers)):
        column = headers[x]["label"]
        if column in lineDataDict:
            worksheet.write(row, x, lineDataDict[column])
    return row


@log_enter_and_exit
def add_patient_overview_table(workbook, patient, workouts):
    """Add a sub table to the file, containing an overview over all workouts of a patient"""

    worksheet = workbook.add_worksheet("Übersicht")
    headers = [
        {"label": "Start", "width": 24},
        {"label": "Trainingswoche", "width": 14},
        {"label": "Trainingstyp", "width": 10.5},
        {"label": "Dauer", "width": 10},
        {"label": "Bewertung", "width": 10},
        {"label": "Intensität", "width": 10},
        {"label": "Kommentar", "width": 20},
        {"label": "Durchschnitts-HF", "width": 15},
        {"label": "Zeit in 01 (%)", "width": 11},
        {"label": "Zeit in 02 (%)", "width": 11},
        {"label": "Zeit in 03 (%)", "width": 11},
        {"label": "Zeit in 04 (%)", "width": 11},
        {"label": "Zeit in 05 (%)", "width": 11},
    ]
    for x in range(len(headers)):
        worksheet.write(0, x, headers[x]["label"])
        worksheet.set_column(x, x, headers[x]["width"])
    lastWrittenRow = 0
    for workout in workouts:
        training_zones = workout.trainingZones_data
        if training_zones != {}:
            zone0 = training_zones["heartRate"]["zone0"]
            zone1 = training_zones["heartRate"]["zone1"]
            zone2 = training_zones["heartRate"]["zone2"]
            zone3 = training_zones["heartRate"]["zone3"]
            zone4 = training_zones["heartRate"]["zone4"]
        else:
            zone0 = 0
            zone1 = 0
            zone2 = 0
            zone3 = 0
            zone4 = 0
        totalZones = max(zone0 + zone1 + zone2 + zone3 + zone4, 1)
        lineDataDict = {
            "Start": format_for_export(workout.startTime),
            "Trainingswoche": force_to_int(
                (
                    datetime.datetime.date(workout.startTime) - patient.treatmentStarted
                ).days
                / 7
            ),
            "Trainingstyp": workout_type_description(workout.type),
            "Dauer": format_for_export(workout.duration / 60),
            "Bewertung": format_for_export(workout.rating()),
            "Intensität": format_for_export(workout.intensity()),
            "Kommentar": workout.comment(),
            "Durchschnitts-HF": format_for_export(workout.heartRateAvg),
            "Zeit in 01 (%)": format_for_export(zone0 / totalZones * 100),
            "Zeit in 02 (%)": format_for_export(zone1 / totalZones * 100),
            "Zeit in 03 (%)": format_for_export(zone2 / totalZones * 100),
            "Zeit in 04 (%)": format_for_export(zone3 / totalZones * 100),
            "Zeit in 05 (%)": format_for_export(zone4 / totalZones * 100),
        }
        lastWrittenRow = add_line_to_worksheet(
            worksheet, lineDataDict, headers, lastWrittenRow
        )
    return worksheet


@log_enter_and_exit
def add_workout_table(workbook, workout):
    """Add a sub table to the file, containing all raw samples for one workout"""

    # Table Names must be unique, this appends an index to workouts if more then one workout was uploaded for one day
    sheetName = format_date(workout.startTime)
    next_date_index = 2
    while workbook.get_worksheet_by_name(sheetName) is not None:
        sheetNameWithIndex = sheetName + " " + str(next_date_index)
        if workbook.get_worksheet_by_name(sheetNameWithIndex) is not None:
            next_date_index += 1
        else:
            sheetName = sheetNameWithIndex

    worksheet = workbook.add_worksheet(sheetName)
    headers = [
        {"label": "Sekunden seit Start (HF)", "width": 21},
        {"label": "HerzFrequenz", "width": 12.5},
        {"label": "", "width": 10},
        {"label": "Sekunden seit Start (Geschw)", "width": 26},
        {"label": "Geschwindigkeit", "width": 15},
        {"label": "", "width": 10},
        {"label": "Sekunden seit Start (Höhe)", "width": 24},
        {"label": "Höhe", "width": 10},
        {"label": "", "width": 10},
        {"label": "Sekunden seit Start (Dist)", "width": 24},
        {"label": "Distanz", "width": 10},
    ]
    for x in range(len(headers)):
        worksheet.write(0, x, headers[x]["label"])
        worksheet.set_column(x, x, headers[x]["width"])
    lastWrittenRow = 0
    heartRateSamples = workout.heartRateSamples_data
    speedSamples = workout.speedSamples_data
    altitudeSamples = workout.altitudeSamples_data
    distanceSamples = workout.distanceSamples_data
    while (
        len(heartRateSamples) > 0
        or len(speedSamples) > 0
        or len(altitudeSamples) > 0
        or len(distanceSamples) > 0
    ):
        heartRateSample = {"seconds_since_start": None, "heartRate": None}
        speedRateSample = {"seconds_since_start": None, "speed": None}
        altitudeRateSample = {"seconds_since_start": None, "altitude": None}
        distanceRateSample = {"seconds_since_start": None, "distance": None}
        if len(heartRateSamples) > 0:
            heartRateSample = heartRateSamples[0]
            heartRateSamples = heartRateSamples[1:]
        if len(speedSamples) > 0:
            speedRateSample = speedSamples[0]
            speedSamples = speedSamples[1:]
        if len(altitudeSamples) > 0:
            altitudeRateSample = altitudeSamples[0]
            altitudeSamples = altitudeSamples[1:]
        if len(distanceSamples) > 0:
            distanceRateSample = distanceSamples[0]
            distanceSamples = distanceSamples[1:]
        lineDataDict = {
            "Sekunden seit Start (HF)": format_for_export(
                heartRateSample["seconds_since_start"]
            ),
            "HerzFrequenz": format_for_export(heartRateSample["heartRate"]),
            "Sekunden seit Start (Geschw)": format_for_export(
                speedRateSample["seconds_since_start"]
            ),
            "Geschwindigkeit": format_for_export(speedRateSample["speed"]),
            "Sekunden seit Start (Höhe)": format_for_export(
                altitudeRateSample["seconds_since_start"]
            ),
            "Höhe": format_for_export(altitudeRateSample["altitude"]),
            "Sekunden seit Start (Dist)": format_for_export(
                distanceRateSample["seconds_since_start"]
            ),
            "Distanz": format_for_export(distanceRateSample["distance"]),
        }
        lastWrittenRow = add_line_to_worksheet(
            worksheet, lineDataDict, headers, lastWrittenRow
        )
    return worksheet
