#!/usr/bin/env python
"""N-queens problem
Deep first search using basic list of list grid
"""


class Board:
    def __init__(self, size):
        self.size = size
        self.boxes = [[0 for c in range(size)] for r in range(size)]

    def solve(self, col):
        if col >= self.size:
            return True
        for row in range(self.size):
            if self.allow(row, col):
                self.boxes[row][col] = 1
                if self.solve(col + 1):
                    return True
            self.boxes[row][col] = 0
        return False

    def allow(self, row, col):
        # Check this row on left side
        for c in range(col):
            if self.boxes[row][c]:
                return False
        # Check upper diagonal on left side
        for r, c in zip(range(row, -1, -1), range(col, -1, -1)):
            if self.boxes[r][c]:
                return False
        # Check lower diagonal on left side
        for r, c in zip(range(row, self.size), range(col, -1, -1)):
            if self.boxes[r][c]:
                return False
        return True

    def display(self):
        for row in range(self.size):
            for col in range(self.size):
                if self.boxes[row][col]:
                    print("* ", end="")
                else:
                    print(". ", end="")
            print()


def main(size=18):
    print(f"solving for size {size}:")
    board = Board(size)
    if board.solve(0):
        board.display()
    else:
        print("No solution.")


if __name__ == "__main__":
    import sys
    from time import perf_counter

    t0 = perf_counter()
    main(int(sys.argv[1]))
    print(f"duration: {perf_counter() - t0:.3f}s")
