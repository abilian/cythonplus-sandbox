"""Fake implementations of soe Cython++ functionalities
"""
from functools import wraps
from contextlib import contextmanager


# annotations
double = float


def cypclass(cls):
    """A do-nothing wrapper"""

    orig_init = cls.__init__

    def __init__(self, *args, **kws):
        self.__is_cypclass = True
        self._active_result_class = "NullResult"
        print("(init some cypclass instance)")
        orig_init(self, *args, **kws)

    cls.__init__ = __init__
    return cls


class Lock:
    def __init__(self):
        pass


def consume(obj):
    obj.__is_consumed = True


def activate(obj):
    obj.__is_active = True


def SequentialMailBox(scheduler):
    return "SequentialMailBox"


@contextmanager
def wlocked(obj):
    resource = obj
    try:
        yield resource
    finally:
        pass


def as_python(function):
    """Another do-nothing wrapper"""

    @wraps(function)
    def wrapper(*args, **kwargs):
        print("< python code")
        function(*args, **kwargs)
        print("python code />")

    return wrapper
