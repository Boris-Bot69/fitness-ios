import datetime

from tumsm_server.database import Column, PkModel, db, reference_col, relationship
from tumsm_server.utils import log_enter_and_exit
from tumsm_server.workout.models import Workout


class PlannedWorkout(PkModel):
    """A planned workout in a training plan"""

    __tablename__ = "plannedWorkouts"

    patientId = reference_col("patients", nullable=False)
    plannedDate = Column(db.Date, nullable=False)
    type = Column(db.Integer, nullable=False)
    maxHeartRate = Column(db.Integer, nullable=True)
    minDuration = Column(db.Integer, nullable=True)
    minDistance = Column(db.Integer, nullable=True)

    @log_enter_and_exit
    def __init__(self, **kwargs):
        """Create instance."""
        super().__init__(**kwargs)

    def __str__(self):
        """Represent instance as a string."""
        return f"<PlannedWorkout>"

    @property
    def asJson(self):
        return {
            "id": self.id,
            "patientId": self.patientId,
            "plannedDate": self.plannedDate,
            "type": self.type,
            "maxHeartRate": self.maxHeartRate,
            "minDuration": self.minDuration,
            "minDistance": self.minDistance,
        }

    @property
    def complete(self):
        foundWorkouts = (
            Workout.query.filter_by(patientId=self.patientId)
            .filter_by(type=self.type)
            .filter(Workout.startTime >= self.plannedDate)
            .filter(Workout.startTime < (self.plannedDate + datetime.timedelta(days=1)))
        )

        if self.minDistance is not None:
            foundWorkouts = foundWorkouts.filter(Workout.distance > self.minDistance)

        if self.minDuration is not None:
            foundWorkouts = foundWorkouts.filter(Workout.duration > self.minDuration)

        return len(foundWorkouts.all()) > 0
