"""Patient forms."""
from wtforms.fields import IntegerField, StringField, FloatField, DateField
from wtforms.validators import DataRequired, Length, Optional, NumberRange, AnyOf

from .models import Patient, PatientTrainingZones
from ..account.models import Account
from ..utils import dateFormat, LoggingFlaskForm


class AddPatientForm(LoggingFlaskForm):
    """Patient form."""

    accountId = IntegerField("Account ID")

    treatmentStarted = DateField(
        "Treatment Start", format=dateFormat, validators=[DataRequired()]
    )
    treatmentFinished = DateField(
        "Treatment Finished", format=dateFormat, validators=[DataRequired()]
    )
    treatmentGoal = StringField(
        "Treatment Goal", validators=[DataRequired(), Length(min=3, max=200)]
    )
    height = IntegerField("Height", validators=[Optional()])
    weight = FloatField("Weight", validators=[Optional()])
    gender = StringField(
        "Gender (m/f/d)", validators=[Optional(), AnyOf(["m", "f", "d"])]
    )
    comment = StringField("Comment", validators=[Optional(), Length(min=3, max=200)])

    def __init__(self, *args, **kwargs):
        """Create instance."""
        super(AddPatientForm, self).__init__(*args, **kwargs)

    def validate_pre_logging(self):
        """Validate the form."""
        if (
            self.accountId.data is not None
            and Account.query.filter_by(id=self.accountId.data).first() is None
        ):
            self.accountId.errors.append("Account does not exist")
            return False
        return True


class AddPatientTrainingZonesForm(LoggingFlaskForm):
    """Patient Trainingzones form."""

    patientId = IntegerField("Patient ID")

    workoutType = IntegerField("Workout Type", validators=[DataRequired()])

    unit = StringField("Unit", validators=[DataRequired(), Length(max=32)])

    upper0Bound = IntegerField(
        "Training Zone 0 Upper Bound", validators=[DataRequired()]
    )

    upper1Bound = IntegerField(
        "Training Zone 1 Upper Bound",
        validators=[DataRequired()],
    )

    upper2Bound = IntegerField(
        "Training Zone 2 Upper Bound",
        validators=[DataRequired()],
    )

    upper3Bound = IntegerField(
        "Training Zone 3 Upper Bound",
        validators=[DataRequired()],
    )

    def __init__(self, *args, **kwargs):
        """Create instance."""
        super(AddPatientTrainingZonesForm, self).__init__(*args, **kwargs)

    def validate_pre_logging(self):
        """Validate the form."""
        if Patient.query.filter_by(id=self.patientId.data).first() is None:
            self.patientId.errors.append("Patient does not exist")
            return False
        return True


class UpdatePatientForm(AddPatientForm):
    def __init__(self, *args, **kwargs):
        super(UpdatePatientForm, self).__init__(*args, **kwargs)
        for field in self:
            field.validators = list(
                filter(
                    lambda validator: not isinstance(validator, DataRequired),
                    field.validators,
                )
            )
            field.validators.append(Optional())
