import json

from tumsm_server.database import Column, PkModel, db, reference_col, relationship
from tumsm_server.utils import log_enter_and_exit


class Workout(PkModel):
    """Workout of an patient"""

    __tablename__ = "workouts"
    appleUUID = Column(db.String(50), nullable=False, default="")
    patientId = reference_col("patients", nullable=False)
    type = Column(db.Integer, nullable=False)
    startTime = Column(db.DateTime, nullable=False)
    endTime = Column(db.DateTime, nullable=False)
    duration = Column(db.Integer, nullable=False)  # In seconds
    kcal = Column(db.Integer, nullable=False)
    distance = Column(db.Float(decimal_return_scale=3), nullable=True)
    terrainUp = Column(db.Float(decimal_return_scale=3), nullable=True)
    terrainDown = Column(db.Float(decimal_return_scale=3), nullable=True)
    heartRateAvg = Column(db.Float(decimal_return_scale=3), nullable=True)
    heartRateMin = Column(db.Integer, nullable=True)
    heartRateMax = Column(db.Integer, nullable=True)
    speedAvg = Column(db.Float(decimal_return_scale=3), nullable=True)
    speedMin = Column(db.Float(decimal_return_scale=3), nullable=True)
    speedMax = Column(db.Float(decimal_return_scale=3), nullable=True)
    paceMin = Column(db.Float(decimal_return_scale=3), nullable=True)
    paceMax = Column(db.Float(decimal_return_scale=3), nullable=True)
    trainingZones = Column(db.LargeBinary, nullable=True)
    heartRateSamples = Column(db.LargeBinary, nullable=True)
    speedSamples = Column(db.LargeBinary, nullable=True)
    altitudeSamples = Column(db.LargeBinary, nullable=True)
    distanceSamples = Column(db.LargeBinary, nullable=True)
    kilometerPace = Column(db.LargeBinary, nullable=True)

    ratings = relationship("WorkoutRating", cascade="all,delete", backref="workout")
    rawJson = relationship("RawWorkout", cascade="all,delete", backref="workout")

    @log_enter_and_exit
    def __init__(self, **kwargs):
        """Create instance."""
        super().__init__(**kwargs)

    def __str__(self):
        """Represent instance as a unique string."""
        return f"<Workout({self.patient.account.full_name} - {self.startTime.strftime('%d/%m/%Y, %H:%M:%S')})>"

    def rating(self):
        if len(self.ratings) == 0:
            return -1
        return self.ratings[-1].rating

    def intensity(self):
        if len(self.ratings) == 0:
            return -1
        return self.ratings[-1].intensity

    def comment(self):
        if len(self.ratings) == 0:
            return ""
        return self.ratings[-1].comment

    def mainHeartRate_segment(self):
        training_zones = self.trainingZones_data
        if (
            "heartRate" not in training_zones
            or training_zones["heartRate"] is None
            or "zone0" not in training_zones["heartRate"]
        ):
            return -1
        heartRateZones = training_zones["heartRate"]
        zone0 = heartRateZones["zone0"]
        zone1 = heartRateZones["zone1"]
        zone2 = heartRateZones["zone2"]
        zone3 = heartRateZones["zone3"]
        zone4 = heartRateZones["zone4"]
        zone_max = max(zone0, zone1, zone2, zone3, zone4)
        if zone0 == zone_max:
            return 0
        if zone1 == zone_max:
            return 1
        if zone2 == zone_max:
            return 2
        if zone3 == zone_max:
            return 3
        if zone4 == zone_max:
            return 4

    @property
    def trainingZones_data(self):
        if self.trainingZones is not None:
            data = json.loads(self.trainingZones.decode())
            if data is not None:
                return data
        return {}

    @property
    def heartRateSamples_data(self):
        if self.heartRateSamples is not None:
            data = json.loads(self.heartRateSamples.decode())
            if data is not None:
                return data
        return []

    @property
    def speedSamples_data(self):
        if self.speedSamples is not None:
            data = json.loads(self.speedSamples.decode())
            if data is not None:
                return data
        return []

    @property
    def altitudeSamples_data(self):
        if self.altitudeSamples is not None:
            data = json.loads(self.altitudeSamples.decode())
            if data is not None:
                return data
        return []

    @property
    def distanceSamples_data(self):
        if self.distanceSamples is not None:
            data = json.loads(self.distanceSamples.decode())
            if data is not None:
                return data
        return []

    @property
    def kilometerPace_data(self):
        if self.kilometerPace is not None:
            data = json.loads(self.kilometerPace.decode())
            if data is not None:
                return data
        return []

    @property
    def asJson(self):
        return {
            "rating": self.rating(),
            "intensity": self.intensity(),
            "comment": self.comment(),
            "type": self.type,
            "startTime": self.startTime,
            "endTime": self.endTime,
            "duration": self.duration,
            "kcal": self.kcal,
            "distance": self.distance,
            "terrainUp": self.terrainUp,
            "terrainDown": self.terrainDown,
            "heartRateAvg": self.heartRateAvg,
            "heartRateMin": self.heartRateMin,
            "heartRateMax": self.heartRateMax,
            "speedAvg": self.speedAvg,
            "speedMin": self.speedMin,
            "speedMax": self.speedMax,
            "paceMin": self.paceMin,
            "paceMax": self.paceMax,
            "trainingZones": self.trainingZones_data,
            "heartRateSamples": self.heartRateSamples_data,
            "speedSamples": self.speedSamples_data,
            "altitudeSamples": self.altitudeSamples_data,
            "distanceSamples": self.distanceSamples_data,
            "kilometerPace": self.kilometerPace_data,
        }


class WorkoutRating(PkModel):
    """Rating of a workout"""

    __tablename__ = "workoutRatings"
    workoutId = reference_col("workouts", nullable=False)
    rating = Column(db.Integer, nullable=False)
    intensity = Column(db.Integer, nullable=False)
    comment = Column(db.String(280), nullable=True)

    @log_enter_and_exit
    def __init__(self, **kwargs):
        """Create instance."""
        super().__init__(**kwargs)

    def __str__(self):
        """Represent instance as a unique string."""
        return f"<WorkoutRating({self.workout.patient.account.full_name} - {self.rating} - {self.intensity})>"


class Steps(PkModel):
    """Steps of an patient on one day"""

    __tablename__ = "steps"
    patientId = reference_col("patients", nullable=False)
    date = Column(db.Date, nullable=False)
    amount = Column(db.Integer, nullable=False)

    @log_enter_and_exit
    def __init__(self, **kwargs):
        """Create instance."""
        super().__init__(**kwargs)

    def __str__(self):
        """Represent instance as a unique string."""
        return f"<Steps({self.patient.account.full_name} - {self.date.strftime('%d/%m/%Y')})>"

    @property
    def asJson(self):
        return {
            "id": self.id,
            "patientId": self.patientId,
            "date": self.date,
            "amount": self.amount,
        }


class RawWorkout(PkModel):
    __tablename__ = "rawWorkout"
    workoutId = reference_col("workouts", nullable=False)
    healthKitJson = Column(db.LargeBinary, nullable=False)

    @log_enter_and_exit
    def __init__(self, **kwargs):
        """Create instance."""
        super().__init__(**kwargs)

    def __str__(self):
        """Represent instance as a unique string."""
        return f"<RawWorkout({self.appleUUID})>"
