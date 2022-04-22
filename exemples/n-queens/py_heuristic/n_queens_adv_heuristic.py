#!/usr/bin/env python
"""N-queens problem
Heuristic using advanced 1D list of queens positions
"""
from time import perf_counter

MAX_DISPLAY = 80


class Rnd:
    def __init__(self):
        self.xn = 42

    def __call__(self, n):
        self.xn = (1664525 * self.xn + 101390423) % 2**32
        return int(self.xn / 2**32 * n)


rnd = Rnd()


class Board:
    def __init__(self, size):
        self.size = size
        self.large = 2 * size + 1
        # queens list, as 1D position
        self.queens = []
        # initialize at random column position
        for row in range(size):
            self.queens.append(row * size + rnd(size))

    def seen(self, q, col, dia1, dia2):
        if col == q % self.size:
            return 1
        if dia1 == (q % self.size + q // self.size) % self.large:
            return 1
        if dia2 == (q % self.size - q // self.size) % self.large:
            return 1
        return 0

    def hit_number(self, x):
        # count nb of hits with queens on other rows:
        row = x // self.size
        col = x % self.size
        dia1 = (col + row) % self.large
        dia2 = (col - row) % self.large
        return sum(self.seen(q, col, dia1, dia2) for q in self.queens[0:row]) + sum(
            self.seen(q, col, dia1, dia2) for q in self.queens[row + 1 :]
        )

    def solve(self):
        while True:
            conflict_queens = []
            for q in self.queens:
                if self.hit_number(q) == 0:
                    continue
                conflict_queens.append(q)
            if not conflict_queens:
                return
            while conflict_queens:
                # maybe move this queen:
                q = conflict_queens.pop(rnd(len(conflict_queens)))
                row = q // self.size
                # find a column with minimal conflicts
                candidates = []
                min_hits = 2**30
                for c in range(self.size):
                    try_pos = row * self.size + c
                    hits = self.hit_number(try_pos)
                    if hits <= min_hits:
                        if hits < min_hits:
                            candidates = []
                            min_hits = hits
                        candidates.append(try_pos)
                chosen = candidates[rnd(len(candidates))]
                # so we have the new position for the queen of this row
                self.queens[row] = chosen

    def display(self):
        if self.size > MAX_DISPLAY:
            return
        set_queens = set(self.queens)
        for row in range(self.size):
            for col in range(self.size):
                if (row * self.size + col) in set_queens:
                    print("* ", end="")
                else:
                    print(". ", end="")
            print()


def main(size=100, runs=5):
    for i in range(runs):
        t0 = perf_counter()
        print(f"solving for size {size}")
        board = Board(size)
        board.solve()
        board.display()
        print(f"duration for size {size}: {perf_counter() - t0:3.3f}s")


if __name__ == "__main__":
    import sys

    size = 100
    runs = 5
    if len(sys.argv > 1):
        size = int(sys.argv[1])
    if len(sys.argv > 2):
        runs = int(sys.argv[2])

    main(size, runs)
    print(f"total duration: {perf_counter() - t0:.3f}s")
