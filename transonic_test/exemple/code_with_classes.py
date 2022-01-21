#!/usr/bin/env python
# golomb sequence with class

from typing import Dict
from transonic import boost


@boost(activable=True)
class Golomb:
    """Use of decorator boost(activable=True) will transform into activable
    cypclass.
    """

    rank: int
    value: int

    def __init__(self, rank: int):
        loc: int

        loc = 5
        self.rank = rank + loc
        g = Gpos(rank)
        self.value = g.gpos(rank)

    def some_meth(self, param: str):
        self.value = len(param)


class NoBoost:
    """No boost decorator: class not exported into .pxd"""

    def __init(self):
        self.x = 1


@boost
class Gpos:
    """Use of decorator boost will transform into cypclass."""

    flrank: float
    xrank: int
    gpos: int
    message: str

    def __init__(self, rank: int, ratio: float, msg: str):
        self.flrank = 1.0 + ratio
        self.xrank = rank + 42
        self.message = msg

    def gpos(self, n: int) -> int:
        """Return the value of position n of the Golomb sequence (recursive function)."""
        if n == 1:
            return 1
        return self.gpos(n - self.gpos(self.gpos(n - 1))) + 1

    def another_gpos(self, n: int) -> int:
        """Return the value of position n of the Golomb sequence (recursive function)."""
        if n == 1:
            return 1
        return self.gpos(n - self.gpos(self.gpos(n - 1))) + 1


@boost
class Recorder:
    """The file src/transonic/nckends/cythonplus.toml contains custom
    definition types.
    """

    storage: Dict[int, int]
    txt_storage: Dict[str, int]

    def __init__(self):
        self.storage = {}
        self.txt_storage = {}

    def store(self, key: int, value: int):
        self.storage[key] = value
        self.txt_storage[str(key)] = value

    def content(self) -> Dict[str, int]:
        return self.txt_storage
