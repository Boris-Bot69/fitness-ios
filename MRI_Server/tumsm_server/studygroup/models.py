from sqlalchemy.orm import backref

from tumsm_server.database import Column, PkModel, db, reference_col, relationship
from tumsm_server.utils import log_enter_and_exit


class StudyGroup(PkModel):
    """A studygroup"""

    __tablename__ = "studyGroups"
    name = Column(db.String(80), unique=True, nullable=False)

    members = relationship(
        "StudyGroupPatients", cascade="all,delete", backref="studygroup"
    )
    trainers = relationship(
        "StudyGroupTrainers", cascade="all,delete", backref="studygroup"
    )

    @log_enter_and_exit
    def __init__(self, name, **kwargs):
        """Create instance."""
        super().__init__(name=name, **kwargs)

    def __str__(self):
        """Represent instance as a string."""
        return f"<StudyGroup({self.name})>"


class StudyGroupPatients(PkModel):
    """Mapping of patients to a studygroup"""

    __tablename__ = "studyGroupPatients"
    studyGroupId = reference_col("studyGroups", nullable=False)
    patientId = reference_col("patients", nullable=False)

    @log_enter_and_exit
    def __init__(self, **kwargs):
        """Create instance."""
        super().__init__(**kwargs)


class StudyGroupTrainers(PkModel):
    """Mapping of trainers to a studygroup"""

    __tablename__ = "studyGroupTrainers"
    studyGroupId = reference_col("studyGroups", nullable=False)
    trainerId = reference_col("trainers", nullable=False)

    @log_enter_and_exit
    def __init__(self, **kwargs):
        """Create instance."""
        super().__init__(**kwargs)
