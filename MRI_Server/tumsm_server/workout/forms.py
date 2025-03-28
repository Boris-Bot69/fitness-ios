"""Workout forms."""
from wtforms import IntegerField, StringField, DateField
from wtforms.validators import DataRequired, Length, NumberRange, Optional

import tumsm_server.patient.models as PatientModel
from .healthkitDataProcessor import check_health_kit_data_structure
from .models import Workout, WorkoutRating
from ..utils import dateFormat, LoggingFlaskForm


class AddStepsForm(LoggingFlaskForm):
    """Steps form."""

    patientId = IntegerField("Patient ID")

    date = DateField("Date", format=dateFormat, validators=[DataRequired()])

    amount = IntegerField("Amount")

    def __init__(self, *args, **kwargs):
        """Create instance."""
        super(AddStepsForm, self).__init__(*args, **kwargs)

    def validate_pre_logging(self):
        """Validate the form."""
        if PatientModel.Patient.query.filter_by(id=self.patientId.data).first() is None:
            self.patientId.errors.append("Patient does not exist")
            return False
        return True


class AddWorkoutForm(LoggingFlaskForm):
    """Workout form."""

    patientId = IntegerField("Patient ID")

    healthJsonData = StringField("Healthkit JSON data", validators=[DataRequired()])

    def __init__(self, *args, **kwargs):
        """Create instance."""
        super(AddWorkoutForm, self).__init__(*args, **kwargs)

    def validate_pre_logging(self):
        """Validate the form."""
        if PatientModel.Patient.query.filter_by(id=self.patientId.data).first() is None:
            self.patientId.errors.append("Patient does not exist")
            return False
        if not check_health_kit_data_structure(self.healthJsonData.data):
            self.healthJsonData.errors.append(
                "Health data does not conform to expected structure"
            )
            return False
        return True


class AddWorkoutRating(LoggingFlaskForm):
    """Workout form."""

    workoutId = IntegerField("Workout ID")

    rating = IntegerField("Rating", validators=[NumberRange(min=0, max=3)])

    intensity = IntegerField("Intensity", validators=[NumberRange(min=1, max=20)])

    comment = StringField("Comment", validators=[Optional(), Length(min=3, max=280)])

    def __init__(self, *args, **kwargs):
        """Create instance."""
        super(AddWorkoutRating, self).__init__(*args, **kwargs)

    def validate_pre_logging(self):
        """Validate the form."""
        if (
            self.workoutId.data is not None
            and Workout.query.filter_by(id=self.workoutId.data).first() is None
        ):
            self.workoutId.errors.append("Workout does not exist")
            return False
        return True


class UpdateWorkoutRating(AddWorkoutRating):
    """Workout update form."""

    def __init__(self, *args, **kwargs):
        super(UpdateWorkoutRating, self).__init__(*args, **kwargs)
        for field in self:
            field.validators = list(
                filter(
                    lambda validator: not isinstance(validator, DataRequired),
                    field.validators,
                )
            )
            field.validators.append(Optional())
