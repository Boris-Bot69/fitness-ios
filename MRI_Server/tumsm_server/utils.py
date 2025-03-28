"""Helper utilities and decorators."""
import functools
import logging
import datetime
import math
import threading
import inspect
import os
import pathlib

from flask import flash
from flask_wtf import FlaskForm

dateTimeFormat = "%Y-%m-%d %H:%M:%S.%f"
dateFormat = "%Y-%m-%d"
threadLocal = threading.local()
maxLoggingValueLength = 30


class LoggingFlaskForm(FlaskForm):
    """Wrapper for FLaskForm which adds logging of validation errors"""

    def __init__(self, *args, **kwargs):
        super(LoggingFlaskForm, self).__init__(*args, **kwargs)

    def validate_pre_logging(self, extra_validators=None):
        return True

    def validate(self, extra_validators=None):
        log("> validate(...)")
        retval = super(LoggingFlaskForm, self).validate(
            extra_validators=extra_validators
        )
        if not retval:
            return False
        retval = self.validate_pre_logging()
        for field in self:
            if len(field.errors) > 0:
                log(f"\t{field.name}: {field.errors}")
        log(f"< validate -> {retval}")
        return retval


def flash_errors(form, category="warning"):
    """Flash all errors for a form."""
    for field, errors in form.errors.items():
        for error in errors:
            flash(f"{getattr(form, field).label.text} - {error}", category)


def format_date(date):
    return datetime.datetime.strftime(date, dateFormat)


def format_date_time(date_time):
    return datetime.datetime.strftime(date_time, dateTimeFormat)


def myMakeRecord(self, name, level, fn, lno, msg, args, exc_info, func, extra, sinfo):
    if extra is not None:
        fn = extra["filename"]
        lno = extra["lineno"]
    rv = logging.LogRecord(name, level, fn, lno, msg, args, exc_info, func, sinfo)
    if extra is not None:
        rv.__dict__.update(extra)
    return rv


def log(msg):
    if not hasattr(threadLocal, "indent"):
        threadLocal.indent = ""

    caller = inspect.currentframe().f_back
    override = {
        "lineno": caller.f_lineno,
        "filename": pathlib.PurePath(caller.f_code.co_filename).parent.name
        + "|"
        + os.path.basename(caller.f_code.co_filename),
    }
    logging.info(f"{threadLocal.indent}\t{msg}", extra=override)


def log_enter_and_exit(func):
    """Print the function signature and return value when called.

    Example:
        Let's define a method and decorate it with our `@debug` decorator
        >>> @debug
        ... def get_greeting(who="World", also_print=False):
        ...     if also_print:
        ...         print(f"Hello, {who}!")
        ...     return f"Hello, {who}!"

        When the method is called, its call signature and return value are printed:
        >>> _ = get_greeting("Reader", also_print=True)
        > get_greeting('Reader', also_print=True)
        Hello, Reader!
        < get_greeting -> 'Hello, Reader!'

    """
    logging.Logger.makeRecord = myMakeRecord

    @functools.wraps(func)
    def wrapper_debug(*args, **kwargs):
        if not hasattr(threadLocal, "indent"):
            threadLocal.indent = ""
        args_repr = [
            repr(a)
            if len(repr(a)) < maxLoggingValueLength
            else repr(a)[: math.floor(maxLoggingValueLength / 2)]
            + "..."
            + repr(a)[math.floor(-maxLoggingValueLength / 2) :]
            for a in args
        ]
        kwargs_repr = [
            f"{k}={v!r}"
            if len(repr(v)) < maxLoggingValueLength
            else f"{k}={repr(v)[:math.floor(maxLoggingValueLength / 2)] + '...' + repr(v)[math.floor(-maxLoggingValueLength / 2):]}"
            for k, v in kwargs.items()
        ]
        caller = inspect.currentframe().f_back
        override = {
            "lineno": caller.f_lineno,
            "filename": pathlib.PurePath(caller.f_code.co_filename).parent.name
            + "|"
            + os.path.basename(caller.f_code.co_filename),
        }
        logging.info(
            f"{threadLocal.indent}> {func.__name__}({', '.join(args_repr + kwargs_repr)})",
            extra=override,
        )
        threadLocal.indent = threadLocal.indent + "\t"
        rv = func(*args, **kwargs)
        threadLocal.indent = threadLocal.indent[:-1]
        rv_repr = f" -> {rv!r}" if rv is not None else ""
        if len(rv_repr) > maxLoggingValueLength:
            rv_repr = (
                " -> "
                + repr(rv)[: math.floor(maxLoggingValueLength / 2)]
                + "..."
                + repr(rv)[math.floor(-maxLoggingValueLength / 2) :]
            )
        logging.info(f"{threadLocal.indent}< {func.__name__}{rv_repr}", extra=override)
        return rv

    return wrapper_debug


def parse_date_time(date_time_string):
    return datetime.datetime.strptime(date_time_string, dateTimeFormat)


def parse_date(date_string):
    return datetime.datetime.strptime(date_string, dateFormat)


def workout_type_description(workout_type):
    if workout_type == 37:
        return "Running"
    elif workout_type == 13:
        return "Cycling"
    return "Other"


def force_to_float(numeric_value):
    try:
        return float(numeric_value)
    except TypeError as e:
        logging.warning("conversion to float failed (%s)", str(e))
        return None


def force_to_int(numeric_value):
    try:
        return int(numeric_value)
    except TypeError as e:
        logging.warning("conversion to int failed (%s)", str(e))
        return None


def force_to_date(date_or_datetime):
    if isinstance(date_or_datetime, datetime.datetime):
        return date_or_datetime.date()
    elif isinstance(date_or_datetime, datetime.date):
        return date_or_datetime
    else:
        raise TypeError(f"'{date_or_datetime}' is neither a date nor datetime")
