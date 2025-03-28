"""Contains Methods to parse the healthkit data provided by the iPhone App into usable objects"""


import json
import math
from json import JSONDecodeError

from tumsm_server.utils import parse_date_time, log_enter_and_exit


@log_enter_and_exit
def check_health_kit_data_structure(health_kit_json_data):
    """Checks the structural (!!not semantical!!) integrity of the healthkit string
    Used for data validation when posting a workout
    """
    try:
        if isinstance(health_kit_json_data, str):
            data = json.loads(health_kit_json_data)
        else:
            data = health_kit_json_data
        data["appleUUID"]
        data["activityType"]
        parse_date_time(data["startDate"])
        parse_date_time(data["endDate"])
        data["duration"]["doubleValue"]
        data["totalDistance"]["doubleValue"]
        data["totalCalories"]["doubleValue"]
        data["workoutEvents"]
        data["heartRateSamples"]
        data["locations"]
        data["distanceWalkingRunningSamples"]
        return True
    except (TypeError, KeyError, ValueError, UnicodeError, JSONDecodeError):
        return False


@log_enter_and_exit
def process_health_kit_data(health_kit_json_data):
    """Consumes the raw healthkit string and parses its contents"""

    try:
        if isinstance(health_kit_json_data, str):
            json_object = json.loads(health_kit_json_data)
        else:
            json_object = health_kit_json_data
        (
            apple_uuid,
            workout_type,
            start_date,
            end_date,
            duration,
            distance,
            kcal,
        ) = get_workout_quick_facts(json_object)
        terrain_up, terrain_down = get_terrain_facts(json_object)
        heart_rate_profile = get_heart_rate_profile(json_object)
        speed_profile = get_speed_profile(json_object)
        altitude_profile = get_altitude_profile(json_object)
        distance_profile = get_distance_profile(json_object)
        (
            heartRateAvg,
            heartRateMin,
            heartRateMax,
            speedAvg,
            speedMin,
            speedMax,
        ) = get_sample_overview(heart_rate_profile, speed_profile)
        return (
            apple_uuid,
            workout_type,
            start_date,
            end_date,
            duration,
            kcal,
            distance,
            terrain_up,
            terrain_down,
            heartRateAvg,
            heartRateMin,
            heartRateMax,
            speedAvg,
            speedMin,
            speedMax,
            heart_rate_profile,
            speed_profile,
            altitude_profile,
            distance_profile,
        )
    except (TypeError, JSONDecodeError):
        return None


@log_enter_and_exit
def get_sample_overview(heartRate_profile, speed_profile):
    """Calculates overview data for heartrate and speed samples"""
    heartRate_sum = 0
    heartRateMin = None
    heartRateMax = None
    speed_sum = 0
    speedMin = None
    speedMax = None
    for sample in heartRate_profile:
        heartRate = sample["heartRate"]
        heartRate_sum += heartRate
        if heartRateMin is None or heartRateMin > heartRate:
            heartRateMin = heartRate
        if heartRateMax is None or heartRateMax < heartRate:
            heartRateMax = heartRate
    for sample in speed_profile:
        speed = sample["speed"]
        speed_sum += speed
        if speedMin is None or speedMin > speed:
            speedMin = speed
        if speedMax is None or speedMax < speed:
            speedMax = speed
    return (
        heartRate_sum / max(len(heartRate_profile), 1),
        heartRateMin,
        heartRateMax,
        speed_sum / max(len(speed_profile), 1),
        speedMin,
        speedMax,
    )


def seconds_since_start(start_date_time, current_date_time):
    """Helper method to calculate seconds since a given point time"""
    return (current_date_time - start_date_time).total_seconds()


def get_device_model(device_string):
    """Extract the device model from a raw device string provided by healthkit"""
    if not (device_string.startswith("Optional(<<") and device_string.endswith(">)")):
        return ""
    if device_string.find("Watch") != -1:
        return "Watch"
    elif device_string.find("iPhone") != -1:
        return "iPhone"
    else:
        return ""


def cut_device_data(device_string):
    """Cuts a comparable string out of the raw device string"""
    # The raw device string also contains a part which can change during a workout, which prevents it from being
    # used to compare the devices which provide samples to healthkit
    if not (device_string.startswith("Optional(<<") and device_string.endswith(">)")):
        return ""
    return device_string.split(">, ", 1)[1]


def get_workout_quick_facts(data):
    """Parses easily accessible data of the workout"""
    apple_uuid = data["appleUUID"]
    workout_type = data["activityType"]
    start_date = parse_date_time(data["startDate"])
    end_date = parse_date_time(data["endDate"])
    duration = data["duration"]["doubleValue"]
    distance = data["totalDistance"]["doubleValue"]
    kcal = data["totalCalories"]["doubleValue"]
    return apple_uuid, workout_type, start_date, end_date, duration, distance, kcal


def get_prioritized_device(data):
    """Iterates over all distanceWalkingRunning samples and determines a device whose samples should be used"""
    # Samples of different devices (e.g. iPhone & iWatch) differ from each other, so they can't both be used
    # at the same time
    # Chooses iWatch over iPhone
    iphone_device = ""
    for sample in data["distanceWalkingRunningSamples"]:
        if get_device_model(sample["device"]) == "Watch":
            return cut_device_data(sample["device"])
        if iphone_device == "" and get_device_model(sample["device"]) == "iPhone":
            iphone_device = sample["device"]
    if (
        data["distanceWalkingRunningSamples"] is None
        or len(data["distanceWalkingRunningSamples"]) == 0
    ):
        return ""
    elif iphone_device == "":
        return cut_device_data(data["distanceWalkingRunningSamples"][0]["device"])
    else:
        return cut_device_data(iphone_device)


def get_altitude_profile(data):
    """Extracts altitude samples into a list"""
    profile = []

    if data["locations"] is None or len(data["locations"]) == 0:
        return []

    first_timestamps = data["locations"][0]["timestamp"]

    for sample in data["locations"]:
        profile.append(
            {
                "altitude": sample["altitude"],
                "seconds_since_start": seconds_since_start(
                    parse_date_time(first_timestamps),
                    parse_date_time(sample["timestamp"]),
                ),
            }
        )
    return profile


def get_terrain_facts(data):
    """Calculates terrain up/down delta of the whole workout"""
    if data["locations"] is None or len(data["locations"]) == 0:
        return 0, 0

    sum_up = 0
    sum_down = 0

    previous_height = data["locations"][0]["altitude"]
    for sample in data["locations"]:
        if sample["altitude"] > previous_height:
            sum_up += sample["altitude"] - previous_height
        elif sample["altitude"] < previous_height:
            sum_down += previous_height - sample["altitude"]
        previous_height = sample["altitude"]
    return sum_up, sum_down


def get_speed_profile(data):
    """Extracts speed samples into a list"""
    profile = []

    if (data["locations"] is None or len(data["locations"]) == 0) and (
        data["distanceWalkingRunningSamples"] is None
        or len(data["distanceWalkingRunningSamples"]) == 0
    ):
        return []
    elif data["locations"] is None or len(data["locations"]) == 0:
        return _get_speed_profile_without_location_data_(data)

    first_timestamps = data["locations"][0]["timestamp"]

    for sample in data["locations"]:
        profile.append(
            {
                "speed": sample["speed"]["doubleValue"] * 3.6,
                "seconds_since_start": seconds_since_start(
                    parse_date_time(first_timestamps),
                    parse_date_time(sample["timestamp"]),
                ),
            }
        )
    return profile


def _get_speed_profile_without_location_data_(data):
    """Extracts altitude samples into a list, when no location data is provided"""
    profile = []

    if (
        data["distanceWalkingRunningSamples"] is None
        or len(data["distanceWalkingRunningSamples"]) == 0
    ):
        return []

    first_timestamps = data["distanceWalkingRunningSamples"][0]["startTime"]
    prioritized_device = get_prioritized_device(data)

    for sample in data["distanceWalkingRunningSamples"]:
        if cut_device_data(sample["device"]) != prioritized_device:
            continue
        meters = float(sample["quantity"]["doubleValue"])
        timeDiff = (
            parse_date_time(sample["endTime"]) - parse_date_time(sample["startTime"])
        ).total_seconds()
        if timeDiff != 0:
            profile.append(
                {
                    "speed": meters / timeDiff * 3.6,
                    "seconds_since_start": seconds_since_start(
                        parse_date_time(first_timestamps),
                        parse_date_time(sample["endTime"]),
                    ),
                }
            )
    return profile


def get_heart_rate_profile(data):
    """Extracts heart rate samples into a list"""
    profile = []

    if data["heartRateSamples"] is None or len(data["heartRateSamples"]) == 0:
        return []

    first_timestamps = data["heartRateSamples"][0]["startTime"]

    for sample in data["heartRateSamples"]:
        profile.append(
            {
                "heartRate": sample["quantity"]["doubleValue"],
                "seconds_since_start": seconds_since_start(
                    parse_date_time(first_timestamps),
                    parse_date_time(sample["endTime"]),
                ),
            }
        )
    return profile


def get_distance_profile(data):
    """Extracts distance samples into a list"""
    profile = []
    current_sum = 0

    if (
        data["distanceWalkingRunningSamples"] is None
        or len(data["distanceWalkingRunningSamples"]) == 0
    ):
        return []

    first_timestamps = data["distanceWalkingRunningSamples"][0]["startTime"]
    prioritized_device = get_prioritized_device(data)

    for sample in data["distanceWalkingRunningSamples"]:
        if cut_device_data(sample["device"]) != prioritized_device:
            continue
        current_sum += float(sample["quantity"]["doubleValue"])
        profile.append(
            {
                "distance": current_sum,
                "seconds_since_start": seconds_since_start(
                    parse_date_time(first_timestamps),
                    parse_date_time(sample["endTime"]),
                ),
            }
        )
    return profile
