import base64
from threading import Lock
from pathlib import Path
import pandas as pd

from tumsm_server.planning.forms import AddPlannedWorkoutForm
from tumsm_server.planning.models import PlannedWorkout
from tumsm_server.utils import log_enter_and_exit

# Note: The Password for the protection of the template file is: "mri"

import_lock = Lock()
importCachePath = "./import/"

dateKey = "Datum"
typeKey = "Typ"
# maxHeartRateKey = "Maximale Herzfrequenz"
minDurationKey = "Minimale Dauer (min, optional)"
minDistanceKey = "Minimale Distanz (meter, optional)"
runningWorkoutType = 37
cyclingWorkoutType = 13


class PlannedWorkoutsMediator:
    """We cant just use a dict for this, because WTFlask uses 'hasattr' instead of 'in' to check for members"""

    def __init__(
        self, patientId, plannedDate, type, maxHeartRate, minDuration, minDistance
    ):
        self.patientId = patientId
        self.plannedDate = plannedDate
        self.type = type
        self.maxHeartRate = maxHeartRate
        self.minDuration = minDuration
        self.minDistance = minDistance


def parse_import_type_options(typeString):
    if typeString.lower() == "laufen":
        return runningWorkoutType
    elif typeString.lower() == "fahrrad fahren":
        return cyclingWorkoutType
    else:
        return 0


@log_enter_and_exit
def import_planned_workouts(patient, utf8encodedBase64String):
    """Parses an utf8 encoded base64 string to a xlsx file & then parses and adds the content as planned workouts"""
    decodedBytes = base64.b64decode(utf8encodedBase64String.encode("UTF-8"))
    Path(importCachePath).mkdir(exist_ok=True)
    fileName = importCachePath + str(patient.id) + ".xlsx"
    plannedWorkoutMediators = []
    plannedWorkoutIds = []
    try:
        with import_lock:
            file = open(fileName, "wb")
            file.write(decodedBytes)
            file.close()
            dataFrame = pd.read_excel(fileName, sheet_name=0, engine="openpyxl")
            for index, row in dataFrame.iterrows():
                plannedWorkoutMediator = PlannedWorkoutsMediator(
                    patientId=patient.id,
                    plannedDate=row[dateKey],
                    type=parse_import_type_options(row[typeKey]),
                    maxHeartRate=None,  # row[maxHeartRateKey],
                    minDuration=row[minDurationKey],
                    minDistance=row[minDistanceKey],
                )
                plannedWorkoutMediators.append(plannedWorkoutMediator)
    # Catches all exception that might be thrown during the file parsing of the library
    except Exception:
        return False, []
    for plannedWorkoutMediator in plannedWorkoutMediators:
        form = AddPlannedWorkoutForm(obj=plannedWorkoutMediator, meta={"csrf": False})
        if form.validate_on_submit():
            plannedWorkout = PlannedWorkout.create(
                patientId=form.patientId.data,
                plannedDate=form.plannedDate.data,
                type=form.type.data,
                maxHeartRate=form.maxHeartRate.data,
                minDuration=form.minDuration.data,
                minDistance=form.minDistance.data,
            )
            plannedWorkoutIds.append(plannedWorkout.id)
        else:
            return False, []
    return True, plannedWorkoutIds
