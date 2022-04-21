"""N-queens problem
Deep first search using advanced 1D list of queens positions, cython+ monocore
"""

from libc.stdio cimport printf
from libcythonplus.list cimport cyplist
from libcythonplus.set cimport cypset


cdef cypclass Board:
    int size
    int large
    int nb_queens
    cyplist[int] queens

    __init__(self, int size):
        self.size = size
        self.large = 2 * size + 1
        # queens list, as 1D positions
        self.queens = cyplist[int]()
        for i in range(size):
            self.queens.append(-1)
        self.nb_queens = 0

    int solve(self):
        if self.nb_queens >= self.size:
            return 1
        for x in range(self.nb_queens * self.size, (self.nb_queens + 1) * self.size):
            if self.allow(x) == 1:
                self.queens[self.nb_queens] = x
                self.nb_queens += 1
                if self.solve() == 1:
                    return 1
        self.nb_queens -= 1
        return 0

    int allow(self, int x):
        cdef int q

        # Check collision with known queens
        for i in range(self.nb_queens):
            q = self.queens[i]
            if (x - q) % self.size == 0:
                return 0  # same column
            if (
                (x % self.size + x // self.size) - (q % self.size + q // self.size)
            ) % self.large == 0:
                return 0  # same diagonal 1
            if (
                (x % self.size - x // self.size) - (q % self.size - q // self.size)
            ) % self.large == 0:
                return 0  # same diagonal 2
        return 1

    void display(self):
        cdef cypset[int] set_queens
        cdef int x, row, col

        set_queens = cypset[int]()
        for i in range(self.nb_queens):
            set_queens.add(self.queens[i])
        for row in range(self.size):
            for col in range(self.size):
                x = row * self.size + col
                if x in set_queens:
                    printf("* ")
                else:
                    printf(". ")
            printf("\n")


def main(int size=18):
    cdef Board board

    printf("solving for size %d:\n", size)
    board = Board(size)
    if board.solve() == 1:
        board.display()
    else:
        printf("No solution.\n")
