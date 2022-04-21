"""N-queens problem
Deep first search using basic list of list grid, cython+ monocore
"""

from libc.stdio cimport printf
from libcythonplus.list cimport cyplist


cdef cypclass Row:
    cyplist[int] row

    __init__(self, int size):
        self.row = cyplist[int]()
        for i in range(size):
            self.row.append(0)

    void set(self, int col, int value):
        self.row[col] = value

    int get(self, int col):
        return self.row[col]


cdef cypclass Board:
    int size
    cyplist[Row] boxes

    __init__(self, int size):
        self.size = size
        self.boxes = cyplist[Row]()
        for i in range(size):
            self.boxes.append(Row(size))

    void set(self, int row, int col, int value):
        board_row = self.boxes[row]
        board_row.set(col, value)

    int get(self, int row, int col):
        board_row = self.boxes[row]
        return board_row.get(col)

    int solve(self, int col):
        cdef int row

        if col >= self.size:
            return 1
        for row in range(self.size):
            if self.allow(row, col):
                self.set(row, col, 1)
                if self.solve(col + 1):
                    return 1
            self.set(row, col, 0)
        return 0

    int allow(self, int row, int col):
        cdef int i
        cdef int j

        # Check this row on left side
        for c in range(col):
            if self.get(row, c) == 1:
                return 0
        # Check upper diagonal on left side
        i = row
        j = col
        while i >= 0 and j >= 0:
            if self.get(i, j) == 1:
                return 0
            i -= 1
            j -= 1
        # Check lower diagonal on left side
        i = row
        j = col
        while i < self.size and j >= 0:
            if self.get(i, j) == 1:
                return 0
            i += 1
            j -= 1
        return 1

    void display(self):
        for row in range(self.size):
            for col in range(self.size):
                if self.get(row, col) == 1:
                    printf("* ")
                else:
                    printf(". ")
            printf("\n")


def main(int size=18):
    cdef Board board

    printf("solving for size %d:\n", size)
    board = Board(size)
    if board.solve(0):
        board.display()
    else:
        printf("No solution.\n")
