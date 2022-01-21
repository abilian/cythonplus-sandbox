#!/usr/bin/env python
# golomb sequence with class

from transonic import boost


@boost(activable=True)
class Golomb:
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
    def __init(self):
        self.x = 1


@boost
class Gpos:
    xrank: int
    gpos: int

    def __init__(self, rank: int):
        print("44")
        self.xrank = rank

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
    storage: dict

    def __init__(self):
        self.storage = {}

    def store(self, key: int, value: int):
        self.storage[key] = value

    def content(self) -> dict:
        return self.storage
