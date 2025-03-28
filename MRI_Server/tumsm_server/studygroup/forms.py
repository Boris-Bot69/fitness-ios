from wtforms import IntegerField, StringField
from wtforms.validators import DataRequired, Length, Optional

from tumsm_server.patient.models import Patient
from tumsm_server.studygroup.models import StudyGroup
from tumsm_server.trainer.models import Trainer
from tumsm_server.utils import LoggingFlaskForm


class AddStudyGroup(LoggingFlaskForm):
    """Studygroup form."""

    name = StringField(
        "Study Group Name", validators=[DataRequired(), Length(min=3, max=80)]
    )

    def __init__(self, *args, **kwargs):
        """Create instance."""
        super(AddStudyGroup, self).__init__(*args, **kwargs)

    def validate_pre_logging(self):
        """Validate the form."""
        return True


class UpdateStudyGroup(AddStudyGroup):
    """Update Studygroup form."""

    def __init__(self, *args, **kwargs):
        super(UpdateStudyGroup, self).__init__(*args, **kwargs)
        for field in self:
            field.validators = list(
                filter(
                    lambda validator: not isinstance(validator, DataRequired),
                    field.validators,
                )
            )
            field.validators.append(Optional())


class AddStudyGroupPatients(LoggingFlaskForm):
    """Studygroup Patients form."""

    studyGroupId = IntegerField("Study Group ID")

    patientId = IntegerField("Patient Group ID")

    def __init__(self, *args, **kwargs):
        """Create instance."""
        super(AddStudyGroupPatients, self).__init__(*args, **kwargs)

    def validate_pre_logging(self):
        """Validate the form."""
        study_group = StudyGroup.query.filter_by(id=self.studyGroupId.data).first()
        if study_group is None:
            self.studyGroupId.errors.append("This study group does not exist")
            return False
        patient = Patient.query.filter_by(id=self.patientId.data).first()
        if patient is None:
            self.patientId.errors.append("This patient does not exist")
            return False
        return True


class AddStudyGroupTrainers(LoggingFlaskForm):
    """Studygroup Trainers form."""

    studyGroupId = IntegerField("Study Group ID")

    trainerId = IntegerField("Trainer ID")

    def __init__(self, *args, **kwargs):
        """Create instance."""
        super(AddStudyGroupTrainers, self).__init__(*args, **kwargs)

    def validate_pre_logging(self):
        """Validate the form."""
        study_group = StudyGroup.query.filter_by(id=self.studyGroupId.data).first()
        if study_group is None:
            self.studyGroupId.errors.append("This study group does not exist")
            return False
        trainer = Trainer.query.filter_by(id=self.trainerId.data).first()
        if trainer is None:
            self.trainerId.errors.append("This trainer does not exist")
            return False
        return True
