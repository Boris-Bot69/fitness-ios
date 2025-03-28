"""Patient forms."""
import logging

from wtforms import DateField, IntegerField, StringField
from wtforms.validators import DataRequired, Length, Optional

from ..account.models import Account
from .models import Trainer

from ..utils import LoggingFlaskForm


class AddTrainerForm(LoggingFlaskForm):
    """Trainer form."""

    accountId = IntegerField("Account ID")

    def __init__(self, *args, **kwargs):
        """Create instance."""
        super(AddTrainerForm, self).__init__(*args, **kwargs)

    def validate_pre_logging(self):
        """Validate the form."""
        if Account.query.filter_by(id=self.accountId.data).first() is None:
            self.accountId.errors.append("Account does not exist")
            return False
        return True


class UpdateTrainerForm(AddTrainerForm):
    """Trainer update form."""

    def __init__(self, *args, **kwargs):
        super(UpdateTrainerForm, self).__init__(*args, **kwargs)
        for field in self:
            field.validators = list(
                filter(
                    lambda validator: not isinstance(validator, DataRequired),
                    field.validators,
                )
            )
            field.validators.append(Optional())
