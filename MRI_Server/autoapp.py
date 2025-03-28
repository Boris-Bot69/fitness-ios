"""Create an application instance."""
import logging
from os import getenv
from sys import stderr

from tumsm_server.app import create_app

logging.basicConfig(
    level=int(getenv("TUMSM_SERVER_LOGLEVEL", logging.INFO)),
    stream=stderr,
    format="%(message)s (%(module)s.py:%(lineno)d)",
)


app = create_app()
