"""N-queens problem
Heuristic using advanced 1D list of queens positions, cython+ single-core
"""
from libc.stdio cimport printf
from libc.time cimport time, difftime, time_t
from libcythonplus.list cimport cyplist
from libcythonplus.set cimport cypset

cdef int MAX_DISPLAY = 80


cdef cypclass Rnd:
    long xn

    __init__(self):
        self.xn = 42

    int __call__(self, int n):
        cdef double d
        cdef int i

        self.xn = (1664525 * self.xn + 101390423) % 2**32
        d = 1.0 * self.xn / 2**32 * n
        i = int(d)
        return i

cdef Rnd rnd
rnd = Rnd()


cdef cypclass Board:
    int size
    int large
    int nb_queens
    cyplist[int] queens

    __init__(self, int size):
        cdef int q
        cdef int row

        self.size = size
        self.large = 2 * size + 1
        # queens list, as 1D position
        self.queens = cyplist[int]()
        # initialize at random column position
        for row in range(size):
            q = row * size + rnd(size)
            self.queens.append(q)

    int seen(self, int q, int col, int dia1, int dia2):
        if col == q % self.size:
            return 1
        if dia1 == (q % self.size + q // self.size) % self.large:
            return 1
        if dia2 == (q % self.size - q // self.size) % self.large:
            return 1
        return 0

    int hit_number(self, int x):
        cdef int row, col, dia1, dia2
        cdef int q
        cdef int hit_sum

        # count nb of hits with queens on other rows:
        row = x // self.size
        col = x % self.size
        dia1 = (col + row) % self.large
        dia2 = (col - row) % self.large

        hit_sum = 0
        for i in range(row):
            q = self.queens[i]
            hit_sum += self.seen(q, col, dia1, dia2)
        for i in range(row + 1, self.size):
            q = self.queens[i]
            hit_sum += self.seen(q, col, dia1, dia2)
        return hit_sum

    int solve(self):
        cdef cyplist[int] conflict_queens
        cdef cyplist[int] candidates
        cdef int q, row, c, try_pos
        cdef int rnd_idx
        cdef int hits, min_hits

        while 1:
            conflict_queens = cyplist[int]()
            for q in self.queens:
                if self.hit_number(q) == 0:
                    continue
                conflict_queens.append(q)
            if conflict_queens.__len__() == 0:
                return 1

            for q in conflict_queens:
                # move this queen:
                row = q // self.size
                # find a column with minimal conflicts:
                min_hits = 2**30
                candidates = cyplist[int]()
                for c in range(self.size):
                    try_pos = row * self.size + c
                    hits = self.hit_number(try_pos)
                    if hits <= min_hits:
                        if hits < min_hits:
                            candidates.clear()
                            min_hits = hits
                        candidates.append(try_pos)
                rnd_idx = rnd(candidates.__len__())
                # so we have the new position for the queen of this row:
                self.queens[row] = candidates[rnd_idx]

    void display(self):
        cdef cypset[int] set_queens
        cdef int x, row, col

        if self.size > MAX_DISPLAY:
            return
        set_queens = cypset[int]()
        for i in range(self.size):
            set_queens.add(self.queens[i])
        for row in range(self.size):
            for col in range(self.size):
                x = row * self.size + col
                if x in set_queens:
                    printf("* ")
                else:
                    printf(". ")
            printf("\n")


def main(int size=100, int runs=5):
    cdef Board board
    cdef time_t t0, t1
    cdef double dtime

    for i in range(runs):
        t0 = time(NULL)
        printf("solving for size %d\n", size)
        board = Board(size)
        board.solve()
        board.display()
        t1 = time(NULL)
        dtime = difftime(t1, t0)
        printf("duration for size %d: ~%.0fs\n", size, dtime)
