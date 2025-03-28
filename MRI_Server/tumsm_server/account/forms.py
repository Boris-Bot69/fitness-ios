from wtforms.fields import PasswordField, StringField, BooleanField, DateField
from wtforms.validators import DataRequired, Email, Length, Optional
from ..utils import dateFormat, LoggingFlaskForm

from tumsm_server.account.models import Account


class AddAccountForm(LoggingFlaskForm):
    """Account form."""

    username = StringField(
        "Username", validators=[DataRequired(), Length(min=3, max=25)]
    )
    email = StringField(
        "Email", validators=[DataRequired(), Email(), Length(min=6, max=40)]
    )
    password = PasswordField(
        "Password", validators=[DataRequired(), Length(min=6, max=40)]
    )
    birthday = DateField("Birthday", format=dateFormat, validators=[DataRequired()])
    firstName = StringField(
        "First name", validators=[DataRequired(), Length(min=3, max=25)]
    )
    lastName = StringField(
        "Last name", validators=[DataRequired(), Length(min=3, max=25)]
    )
    active = BooleanField("Active", validators=[Optional()])

    def __init__(self, *args, **kwargs):
        """Create instance."""
        super(AddAccountForm, self).__init__(*args, **kwargs)

    def validate_pre_logging(self):
        """Validate the form."""
        patient = Account.query.filter_by(username=self.username.data).first()
        if patient:
            self.username.errors.append("Patient with this username already exists")
            return False
        patient = Account.query.filter_by(email=self.email.data).first()
        if patient:
            self.email.errors.append("Patient with this Email already exists")
            return False
        return True


class UpdateAccountForm(AddAccountForm):
    def __init__(self, *args, **kwargs):
        super(UpdateAccountForm, self).__init__(*args, **kwargs)
        for field in self:
            field.validators = list(
                filter(
                    lambda validator: not isinstance(validator, DataRequired),
                    field.validators,
                )
            )
            field.validators.append(Optional())
