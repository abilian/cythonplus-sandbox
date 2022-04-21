#!/usr/bin/env python
"""N-queens problem
Deep first search using advanced 1D list of queens positions
"""


class Board:
    def __init__(self, size):
        self.size = size
        self.large = 2 * size + 1
        # queens list, as 1D positions
        self.queens = [-1 for x in range(size)]
        self.nb_queens = 0

    def solve(self):
        if self.nb_queens >= self.size:
            return True
        for x in range(self.nb_queens * self.size, (self.nb_queens + 1) * self.size):
            if self.allow(x):
                self.queens[self.nb_queens] = x
                self.nb_queens += 1
                if self.solve():
                    return True
        self.nb_queens -= 1
        return False

    def allow(self, x):
        # Check collision with known queens
        for q in self.queens[: self.nb_queens]:
            if (x - q) % self.size == 0:
                return False  # same column
            if (
                (x % self.size + x // self.size) - (q % self.size + q // self.size)
            ) % self.large == 0:
                return False  # same diagonal 1
            if (
                (x % self.size - x // self.size) - (q % self.size - q // self.size)
            ) % self.large == 0:
                return False  # same diagonal 2
        return True

    def display(self):
        set_queens = set(self.queens)
        for row in range(self.size):
            for col in range(self.size):
                if (row * self.size + col) in set_queens:
                    print("* ", end="")
                else:
                    print(". ", end="")
            print()


def main(size=18):
    print(f"solving for size {size}:")
    board = Board(size)
    if board.solve():
        board.display()
    else:
        print("No solution.")


if __name__ == "__main__":
    import sys
    from time import perf_counter

    t0 = perf_counter()
    main(int(sys.argv[1]))
    print(f"duration: {perf_counter() - t0:.3f}s")
