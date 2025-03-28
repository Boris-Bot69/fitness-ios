"""Patient models."""
import datetime as dt
import json

from flask import jsonify

from tumsm_server.database import Column, PkModel, db, reference_col, relationship
from tumsm_server.planning.lib import cyclingWorkoutType, runningWorkoutType
from tumsm_server.utils import log_enter_and_exit, force_to_date


class Patient(PkModel):
    """An patient that sends health data to this server."""

    __tablename__ = "patients"
    accountId = reference_col("accounts", nullable=True)
    treatmentStarted = Column(db.Date, nullable=False)
    treatmentFinished = Column(db.Date, nullable=False)
    treatmentGoal = Column(db.String(280), nullable=False)
    height = Column(db.Integer, nullable=True)
    weight = Column(db.Float, nullable=True)
    gender = Column(db.String(1), nullable=True)
    comment = Column(db.String(200), nullable=True)

    plannedWorkouts = relationship(
        "PlannedWorkout", cascade="all,delete", backref="patient"
    )

    steps = relationship("Steps", cascade="all,delete", backref="patient")
    trainingZones = relationship(
        "PatientTrainingZones", cascade="all,delete", backref="patient"
    )
    studygroups = relationship(
        "StudyGroupPatients", cascade="all,delete", backref="patient"
    )
    workouts = relationship("Workout", cascade="all,delete", backref="patient")

    @log_enter_and_exit
    def __init__(
        self,
        accountId,
        treatmentStarted,
        treatmentGoal,
        treatmentFinished=None,
        height=None,
        weight=None,
        gender=None,
        comment=None,
        **kwargs,
    ):
        """Create instance."""
        super().__init__(
            accountId=accountId,
            treatmentStarted=treatmentStarted,
            treatmentGoal=treatmentGoal,
            treatmentFinished=treatmentFinished,
            height=height,
            weight=weight,
            gender=gender,
            comment=comment,
            **kwargs,
        )

    def __str__(self):
        """Represent instance as a string."""
        return f"<Patient({self.account.full_name})>"

    @property
    def study_group(self):
        if len(self.studygroups) == 0:
            return None
        return self.studygroups[0].studygroup

    def active_training_zone(self, unit, workoutType):
        zone = PatientTrainingZones.query.filter_by(
            patientId=self.id, active=True, unit=unit, workoutType=workoutType
        ).first()
        if zone is None:
            return None
        return zone.asJson

    def training_zone_of_date(self, unit, date, workoutType):
        date = force_to_date(date)
        trainingZone = None
        oldestTrainingZone = None
        zones = PatientTrainingZones.query.filter_by(
            patientId=self.id, unit=unit, workoutType=workoutType
        ).all()
        for zone in zones:
            if trainingZone is None or (
                zone.creationDate < date and trainingZone > zone.creationDate
            ):
                trainingZone = zone
            if oldestTrainingZone is None or zone.creationDate < oldestTrainingZone:
                oldestTrainingZone = zone
        if trainingZone is None:
            return oldestTrainingZone
        return trainingZone

    @property
    def training_zone_segments_json(self):
        training_zones = [x.asJson for x in PatientTrainingZones.query.filter_by(
            patientId=self.id, active=True
        ).all()]
        return training_zones


class PatientTrainingZones(PkModel):
    """The training zones for an patient"""

    __tablename__ = "patientTrainingZones"
    patientId = reference_col("patients", nullable=True)
    active = Column(db.Boolean, nullable=False)
    creationDate = Column(db.Date, nullable=False, default=dt.datetime.utcnow)
    workoutType = Column(db.Integer, nullable=False)
    unit = Column(db.String(32), nullable=False)

    upper0Bound = Column(db.Integer, nullable=False)
    upper1Bound = Column(db.Integer, nullable=False)
    upper2Bound = Column(db.Integer, nullable=False)
    upper3Bound = Column(db.Integer, nullable=False)

    @log_enter_and_exit
    def __init__(
        self,
        patientId,
        active,
        workoutType,
        unit,
        upper0Bound,
        upper1Bound,
        upper2Bound,
        upper3Bound,
        **kwargs,
    ):
        """Create instance."""
        super().__init__(
            patientId=patientId,
            active=active,
            workoutType=workoutType,
            unit=unit.upper(),
            upper0Bound=upper0Bound,
            upper1Bound=upper1Bound,
            upper2Bound=upper2Bound,
            upper3Bound=upper3Bound,
            **kwargs,
        )

    def __str__(self):
        """Represent instance as a string."""
        return f"<PatientTrainingZones({self.patient.account.full_name} {self.active} {self.creationDate})>"

    @property
    def asJson(self):
        return {
            "id": self.id,
            "workoutType": self.workoutType,
            "unit": self.unit,
            "upper0Bound": self.upper0Bound,
            "upper1Bound": self.upper1Bound,
            "upper2Bound": self.upper2Bound,
            "upper3Bound": self.upper3Bound,
        }
