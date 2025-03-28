"""trainer models."""
from sqlalchemy.orm import backref

from tumsm_server.database import Column, PkModel, db, reference_col, relationship
from tumsm_server.utils import log_enter_and_exit


class Trainer(PkModel):
    """A trainer that is supervising patients"""

    __tablename__ = "trainers"
    accountId = reference_col("accounts", nullable=False)

    studygroups = relationship(
        "StudyGroupTrainers", cascade="all,delete", backref="trainer"
    )

    @log_enter_and_exit
    def __init__(self, accountId, **kwargs):
        """Create instance."""
        super().__init__(accountId=accountId, **kwargs)

    def __str__(self):
        """Represent instance as a string."""
        return f"<Trainer({self.account.full_name})>"
