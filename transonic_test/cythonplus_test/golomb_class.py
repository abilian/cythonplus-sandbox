#!/usr/bin/env python
# golomb sequence with class

from transonic import boost


@boost(activable=True)
class Golomb:
    rank: int
    value: int

    def __init__(self, rank: int):
        self.rank = rank
        g = Gpos(rank)
        self.value = g.gpos(rank)


class NoBoost:
    def __init(self):
        self.x = 1


@boost
class Gpos:
    xrank: int
    gpos: int

    @boost
    def __init__(self, rank: int):
        print("44")
        self.xrank = rank

    @boost
    def gpos(self, n: int) -> int:
        """Return the value of position n of the Golomb sequence (recursive function)."""
        if n == 1:
            return 1
        return self.gpos(n - self.gpos(self.gpos(n - 1))) + 1

    @boost
    def another_gpos(self, n: int) -> int:
        """Return the value of position n of the Golomb sequence (recursive function)."""
        if n == 1:
            return 1
        return self.gpos(n - self.gpos(self.gpos(n - 1))) + 1


@boost
class Recorder:
    def __init__(self):
        self.storage = {}

    def store(self, key: int, value: int):
        self.storage[key] = value

    def content(self) -> dict:
        return self.storage
