from wtforms.fields import IntegerField, StringField, DateField
from wtforms.validators import DataRequired, Length, Optional
import tumsm_server.patient.models as PatientModel

from tumsm_server.utils import log_enter_and_exit, dateFormat, LoggingFlaskForm


class ImportPlannedWorkoutsForm(LoggingFlaskForm):
    """Form for importing multiple planned Workouts from one xlsx file"""

    patientId = IntegerField("Patient ID", validators=[DataRequired()])
    xlsxBase64 = StringField("Xlsx Base64", validators=[DataRequired()])

    @log_enter_and_exit
    def __init__(self, *args, **kwargs):
        """Create instance."""
        super(ImportPlannedWorkoutsForm, self).__init__(*args, **kwargs)

    def validate_pre_logging(self):
        """Validate the form."""
        if PatientModel.Patient.query.filter_by(id=self.patientId.data).first() is None:
            self.patientId.errors.append("Patient does not exist")
            return False
        return True


class AddPlannedWorkoutForm(LoggingFlaskForm):
    """Planned workout form."""

    patientId = IntegerField("Patient ID", validators=[DataRequired()])
    plannedDate = DateField(
        "Planned Date", format=dateFormat, validators=[DataRequired()]
    )
    type = IntegerField("Type", validators=[DataRequired()])
    maxHeartRate = IntegerField("Max Heartrate", validators=[Optional()])
    minDuration = IntegerField("Min Duration", validators=[Optional()])
    minDistance = IntegerField("Min Distance", validators=[Optional()])

    @log_enter_and_exit
    def __init__(self, *args, **kwargs):
        """Create instance."""
        super(AddPlannedWorkoutForm, self).__init__(*args, **kwargs)

    def validate_pre_logging(self):
        """Validate the form."""
        if (
            self.patientId.data is not None
            and PatientModel.Patient.query.filter_by(id=self.patientId.data).first()
            is None
        ):
            self.patientId.errors.append("Patient does not exist")
            return False
        return True


class UpdatePlannedWorkoutForm(AddPlannedWorkoutForm):
    def __init__(self, *args, **kwargs):
        super(UpdatePlannedWorkoutForm, self).__init__(*args, **kwargs)
        for field in self:
            field.validators = list(
                filter(
                    lambda validator: not isinstance(validator, DataRequired),
                    field.validators,
                )
            )
            field.validators.append(Optional())
