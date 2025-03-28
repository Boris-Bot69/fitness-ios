import json
import logging
import math
from json import JSONDecodeError

from .healthkitDataProcessor import process_health_kit_data
from .models import Workout, RawWorkout
import tumsm_server.patient.models as PatientModels
from ..utils import log_enter_and_exit, force_to_float


@log_enter_and_exit
def create_workout(workout_json, patientId, patch=False):
    """Creates/Patches a workout object from a raw healthkit string"""

    try:
        (
            apple_uuid,
            type_p,
            startTime_p,
            endTime_p,
            duration_p,
            kcal_p,
            distance_p,
            terrain_up_p,
            terrain_down_p,
            heartRateAvg_p,
            heartRateMin_p,
            heartRateMax_p,
            speedAvg_p,
            speedMin_p,
            speedMax_p,
            heartRate_samples_p,
            speed_samples_p,
            altitude_samples_p,
            distance_samples_p,
        ) = process_health_kit_data(workout_json)

        # The combined profile with always the same sample rate is used to calculate the data for
        # trainingZones/kilometerPace
        # We need data that always uses the same sample rate to ensure percentage comparability
        combined_profile = get_combined_profile(
            10,
            heart_rate_profile=heartRate_samples_p,
            speed_profile=speed_samples_p,
            altitude_profile=altitude_samples_p,
            distance_profile=distance_samples_p,
            startTime=startTime_p,
            endTime=endTime_p,
        )
        kilometer_pace_p, paceMin_p, paceMax_p = get_kilometre_wise_pace(
            combined_profile
        )

    except TypeError:
        return None

    patient = PatientModels.Patient.query.filter_by(id=patientId).first()
    trainingZoneHeartrate = patient.training_zone_of_date(
        unit="HEARTRATE", date=startTime_p, workoutType=type_p
    )
    trainingZoneSpeed = patient.training_zone_of_date(
        unit="SPEED", date=startTime_p, workoutType=type_p
    )

    workoutContent = {
        "appleUUID": apple_uuid,
        "patientId": patientId,
        "type": type_p,
        "startTime": startTime_p,
        "endTime": endTime_p,
        "duration": duration_p,
        "kcal": kcal_p,
        "distance": distance_p,
        "terrainUp": terrain_up_p,
        "terrainDown": terrain_down_p,
        "heartRateAvg": heartRateAvg_p,
        "heartRateMin": heartRateMin_p,
        "heartRateMax": heartRateMax_p,
        "speedAvg": speedAvg_p,
        "speedMin": speedMin_p,
        "speedMax": speedMax_p,
        "paceMin": paceMin_p,
        "paceMax": paceMax_p,
        "trainingZones": str.encode(
            json.dumps(
                {
                    "heartRate": get_training_zones(
                        trainingZoneHeartrate, combined_profile, type_p, "heartRate"
                    ),
                    "speed": get_training_zones(
                        trainingZoneSpeed, combined_profile, type_p, "speed"
                    ),
                }
            )
        ),
        "heartRateSamples": str.encode(json.dumps(heartRate_samples_p)),
        "speedSamples": str.encode(json.dumps(speed_samples_p)),
        "altitudeSamples": str.encode(json.dumps(altitude_samples_p)),
        "distanceSamples": str.encode(json.dumps(distance_samples_p)),
        "kilometerPace": str.encode(json.dumps(kilometer_pace_p)),
    }

    existing_workout = Workout.query.filter_by(
        appleUUID=apple_uuid, patientId=patientId
    ).first()

    if patch:
        if existing_workout is None:
            return None
        existing_workout.update(**workoutContent)
        return existing_workout
    else:
        if existing_workout is not None:
            return existing_workout
        workout = Workout.create(**workoutContent)
        RawWorkout.create(
            workoutId=workout.id, healthKitJson=str.encode(json.dumps(workout_json))
        )
        return workout


@log_enter_and_exit
def get_training_zones(patientTrainingZone, combined_profile, workoutType, unit):
    """Calculate amount of samples in training zones"""
    if patientTrainingZone is None:
        return None
    total = len(combined_profile)
    zone0count = 0
    zone1count = 0
    zone2count = 0
    zone3count = 0
    zone4count = 0

    for sample in combined_profile:
        value = sample[unit]
        if value is not None:
            if patientTrainingZone is not None:
                if value < patientTrainingZone.upper0Bound:
                    zone0count += 1
                if (
                    patientTrainingZone.upper0Bound
                    <= value
                    < patientTrainingZone.upper1Bound
                ):
                    zone1count += 1
                if (
                    patientTrainingZone.upper1Bound
                    <= value
                    < patientTrainingZone.upper2Bound
                ):
                    zone2count += 1
                if (
                    patientTrainingZone.upper2Bound
                    <= value
                    < patientTrainingZone.upper3Bound
                ):
                    zone3count += 1
                if value > patientTrainingZone.upper3Bound:
                    zone4count += 1
    return {
        "total": total,
        "zone0": zone0count,
        "zone1": zone1count,
        "zone2": zone2count,
        "zone3": zone3count,
        "zone4": zone4count,
    }


@log_enter_and_exit
def get_combined_profile(
    sample_period,
    workout=None,
    heart_rate_profile=None,
    speed_profile=None,
    altitude_profile=None,
    distance_profile=None,
    startTime=None,
    endTime=None,
):
    """Calculate the combined profile from an already finished workout or lists of the respective samples"""
    try:
        if workout is not None:
            heart_rate_profile = workout.heartRateSamples_data
            speed_profile = workout.speedSamples_data
            altitude_profile = workout.altitudeSamples_data
            distance_profile = workout.distanceSamples_data
            startTime = workout.startTime
            endTime = workout.endTime

        heart_rate_pointer = 0
        speed_pointer = 0
        altitude_pointer = 0
        distance_pointer = 0

        result = []
        total_samples = math.ceil((endTime - startTime).seconds / sample_period)
        first_sample_time_offset = 0
        if len(distance_profile) > 0 and distance_profile[0]["distance"] < 200:
            first_sample_time_offset = distance_profile[0]["seconds_since_start"]
        current_lower_bound = first_sample_time_offset
        for i in range(total_samples - 1):
            current_upper_bound = current_lower_bound + sample_period
            bpm = None
            kmh = None
            m_above_sea = None
            distance = None

            if len(heart_rate_profile) > 0:
                bpm, heart_rate_pointer = get_value_for_interval(
                    heart_rate_profile,
                    heart_rate_pointer,
                    "heartRate",
                    current_lower_bound,
                    current_upper_bound,
                )
            if len(speed_profile) > 0:
                kmh, speed_pointer = get_value_for_interval(
                    speed_profile,
                    speed_pointer,
                    "speed",
                    current_lower_bound,
                    current_upper_bound,
                )
            if len(altitude_profile) > 0:
                m_above_sea, altitude_pointer = get_value_for_interval(
                    altitude_profile,
                    altitude_pointer,
                    "altitude",
                    current_lower_bound,
                    current_upper_bound,
                )
            if len(distance_profile) > 0:
                distance, distance_pointer = get_value_for_interval(
                    distance_profile,
                    distance_pointer,
                    "distance",
                    current_lower_bound,
                    current_upper_bound,
                )

            result.append(
                {
                    "heartRate": bpm,
                    "speed": kmh,
                    "altitude": m_above_sea,
                    "distance": distance,
                    "secondsSinceStart": current_lower_bound - first_sample_time_offset,
                }
            )
            current_lower_bound = current_upper_bound
        return result
    except (TypeError, JSONDecodeError):
        return None


def get_value_for_interval(
    value_list, pointer, value_key, lower_time_bound, upper_time_bound
):
    """Generic getter for a sample of an interval from a provided list of samples"""
    iterated = 0
    lastItem = value_list[-1]
    for item_index in range(len(value_list[pointer:])):
        item = value_list[pointer + item_index]
        if lower_time_bound <= item["seconds_since_start"] < upper_time_bound:
            avg_value = 0
            avg_count = 0
            while (pointer + item_index + avg_count) < len(
                value_list
            ) and lower_time_bound <= value_list[pointer + item_index + avg_count][
                "seconds_since_start"
            ] < upper_time_bound:
                avg_value += value_list[pointer + item_index + avg_count][value_key]
                avg_count += 1
            return force_to_float(avg_value / max(avg_count, 1)), pointer + iterated
        elif lower_time_bound <= item["seconds_since_start"] > upper_time_bound:
            if pointer + iterated == 0:
                last_item = {value_key: 0, "seconds_since_start": 0}
            else:
                last_item = value_list[pointer + iterated - 1]
            return (
                interpolate_samples(
                    last_item[value_key],
                    last_item["seconds_since_start"],
                    item[value_key],
                    item["seconds_since_start"],
                    lower_time_bound,
                ),
                pointer + iterated,
            )
        else:
            iterated += 1
            lastItem = item
    return force_to_float(lastItem[value_key]), pointer + iterated


def interpolate_samples(
    previous_value, previous_time, next_value, next_time, wanted_time
):
    """Method that returns an interpolated value using the neighboring samples"""
    sample_time_diff = next_time - previous_time
    sample_value_diff = next_value - previous_value
    time_diff = wanted_time - previous_time
    return float(previous_value + (time_diff / sample_time_diff) * sample_value_diff)


@log_enter_and_exit
def get_kilometre_wise_pace(combined_profile):
    """Calculates duration and avg/max values for speed & heart rate per kilometer"""
    list_size = len(combined_profile)

    sample_rate = 10  # sample rate used to calculate combined_profile

    current_time_sum = 0
    current_heart_rate_sum = None
    max_heart_rate = None
    currentSpeed_sum = None
    maxSpeed = None

    kilometer_pace_list = []

    if list_size == 0 or combined_profile[0]["distance"] is None:
        return [], 0, 0

    old_distance = 0
    samples_in_kilometre_counter = 0
    distance = combined_profile[0]["distance"]

    for index in range(list_size):
        sample = combined_profile[index]
        distance = sample["distance"]
        if distance < (len(kilometer_pace_list) + 1) * 1000:
            samples_in_kilometre_counter += 1
            current_time_sum += sample_rate
            if sample["heartRate"] is not None:
                if current_heart_rate_sum is None:
                    current_heart_rate_sum = sample["heartRate"]
                    max_heart_rate = sample["heartRate"]
                else:
                    current_heart_rate_sum += sample["heartRate"]
                    if max_heart_rate < sample["heartRate"]:
                        max_heart_rate = sample["heartRate"]
            if sample["speed"] is not None:
                if currentSpeed_sum is None:
                    currentSpeed_sum = sample["speed"]
                    maxSpeed = sample["speed"]
                else:
                    currentSpeed_sum += sample["speed"]
                    if maxSpeed < sample["speed"]:
                        maxSpeed = sample["speed"]
        else:
            overhead = distance - (len(kilometer_pace_list) + 1) * 1000
            percentage_overhead = overhead / (distance - old_distance)
            current_time_sum += sample_rate * (1 - percentage_overhead)
            if current_heart_rate_sum is None:
                avg_heart_rate = None
            else:
                avg_heart_rate = current_heart_rate_sum / samples_in_kilometre_counter

            if currentSpeed_sum is None:
                avgSpeed = None
            else:
                avgSpeed = currentSpeed_sum / samples_in_kilometre_counter

            kilometer = KilometerPace(current_time_sum, distance)
            kilometer_pace_list.append(
                {
                    "kilometre": len(kilometer_pace_list) + 1,
                    "minutes": kilometer.minutes,
                    "seconds": force_to_float(kilometer.seconds),
                    "avgHeartRate": force_to_float(avg_heart_rate),
                    "maxHeartRate": force_to_float(max_heart_rate),
                    "avgSpeed": force_to_float(avgSpeed),
                    "maxSpeed": force_to_float(maxSpeed),
                }
            )
            current_time_sum += sample_rate * percentage_overhead
            current_heart_rate_sum = None
            max_heart_rate = 0
            currentSpeed_sum = None
            maxSpeed = 0
            samples_in_kilometre_counter = 0

        old_distance = distance

    if current_heart_rate_sum is None:
        avg_heart_rate = None
    else:
        avg_heart_rate = current_heart_rate_sum / samples_in_kilometre_counter

    if currentSpeed_sum is None:
        avgSpeed = None
    else:
        avgSpeed = currentSpeed_sum / samples_in_kilometre_counter

    last_kilometer = KilometerPace(current_time_sum, distance)
    kilometer_pace_list.append(
        {
            "kilometre": len(kilometer_pace_list) + 1,
            "avgHeartRate": force_to_float(avg_heart_rate),
            "maxHeartRate": force_to_float(max_heart_rate),
            "avgSpeed": force_to_float(avgSpeed),
            "maxSpeed": force_to_float(maxSpeed),
            "minutes": last_kilometer.minutes,
            "seconds": force_to_float(last_kilometer.seconds),
        }
    )
    paceMin = None
    paceMax = None
    for sample in kilometer_pace_list:
        seconds = sample["seconds"] + sample["minutes"] * 60
        if paceMin is None or paceMin > seconds:
            paceMin = seconds
        if paceMax is None or paceMax < seconds:
            paceMax = seconds

    return kilometer_pace_list, paceMin, paceMax


class KilometerPace:
    """Contains information about how long it took an individual to move one kilometre"""

    def __init__(self, seconds, meters):
        secs_per_km = seconds / (meters / 1000)
        self.minutes = math.floor(secs_per_km / 60)
        self.seconds = secs_per_km % 60

    def __str__(self):
        return str(self.minutes) + "'" + str(round(self.seconds)) + '"'
