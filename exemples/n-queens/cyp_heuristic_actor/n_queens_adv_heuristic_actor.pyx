"""N-queens problem
Heuristic using advanced 1D list of queens positions, cython+ actors
"""
from libc.stdio cimport printf
from libc.time cimport time, difftime, time_t
from libcythonplus.list cimport cyplist
from libcythonplus.set cimport cypset
from scheduler.scheduler cimport BatchMailBox, NullResult, Scheduler


ctypedef cyplist[int] IntList


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
cdef IntList[1] global_queens
cdef int MAX_DISPLAY = 80
rnd = Rnd()
global_queens[0] = IntList()


cdef cypclass Recorder activable:
    cyplist[int] storage
    int min_hits

    __init__(self, lock Scheduler scheduler):
        self._active_result_class = NullResult
        self._active_queue_class = consume BatchMailBox(scheduler)
        self.storage = cyplist[int]()
        # hack: we test at storage time we got the minimum hit,
        # so we do not store useless values
        self.min_hits = 2**30

    void store(self, int col, int hits):
        if hits <= self.min_hits:
            if hits < self.min_hits:
                self.storage.clear()  # erase values too big
                self.min_hits = hits
            self.storage.append(col)

    int column(self):
        cdef int rnd_idx
        cdef int col

        rnd_idx = rnd(self.storage.__len__())
        col = self.storage[rnd_idx]
        return col


cdef cypclass HitBoard activable:
    int row
    int col
    int dia1
    int dia2
    int size
    int large
    lock Scheduler scheduler
    active Recorder recorder

    __init__(self,
             lock Scheduler scheduler,
             active Recorder recorder,
             int row,
             int col,
             int size,
             int large
             ):
        self._active_result_class = NullResult
        self._active_queue_class = consume BatchMailBox(scheduler)
        self.recorder = recorder
        self.row = row
        self.col = col
        self.size = size
        self.large = large
        self.dia1 = (col + row) % large
        self.dia2 = (col - row) % large

    int seen(self, int q):
        if self.col == q % self.size:
            return 1
        if self.dia1 == (q % self.size + q // self.size) % self.large:
            return 1
        if self.dia2 == (q % self.size - q // self.size) % self.large:
            return 1
        return 0

    int count_hits(self):
        cdef int q
        cdef int hit_sum
        cdef IntList queens

        queens = global_queens[0]

        hit_sum = 0
        for i in range(self.row):
            q = queens[i]
            hit_sum += self.seen(q)
        for i in range(self.row + 1, self.size):
            q = queens[i]
            hit_sum += self.seen(q)
        return hit_sum

    void run(self):
        self.recorder.store(NULL, self.col, self.count_hits())


cdef cypclass Generator activable:
    int row
    int size
    int large
    lock Scheduler scheduler
    active Recorder recorder

    __init__(self, lock Scheduler scheduler, int row, int size, int large):
        self._active_result_class = NullResult
        self._active_queue_class = consume BatchMailBox(scheduler)
        self.scheduler = scheduler
        self.row = row
        self.size = size
        self.large = large
        self.recorder = activate (consume Recorder(scheduler))

    void run(self):
        cdef int col

        for col in range(self.size):
            hit_board = activate(consume(
                        HitBoard(
                            self.scheduler,
                            self.recorder,
                            self.row,
                            col,
                            self.size,
                            self.large,
                            )))
            hit_board.run(NULL)

    int destination(self):
        cdef int col

        recorder = consume self.recorder
        col = recorder.column()
        return self.row * self.size + col


cdef cypclass Board:
    int size
    int large

    __init__(self, int size):
        cdef int q
        cdef int row
        cdef IntList queens

        queens = global_queens[0]
        queens.clear()
        self.size = size
        self.large = 2 * size + 1
        # initialize at random column position
        for row in range(size):
            q = row * size + rnd(size)
            queens.append(q)

    int seen(self, int q, int col, int dia1, int dia2):
        if col == q % self.size:
            return 1
        if dia1 == (q % self.size + q // self.size) % self.large:
            return 1
        if dia2 == (q % self.size - q // self.size) % self.large:
            return 1
        return 0

    int count_hits(self, int x):
        cdef int row, col, dia1, dia2
        cdef int q
        cdef int hit_sum
        cdef IntList queens

        queens = global_queens[0]
        # count nb of hits with queens on other rows:
        row = x // self.size
        col = x % self.size
        dia1 = (col + row) % self.large
        dia2 = (col - row) % self.large

        hit_sum = 0
        for i in range(row):
            q = queens[i]
            hit_sum += self.seen(q, col, dia1, dia2)
        for i in range(row + 1, self.size):
            q = queens[i]
            hit_sum += self.seen(q, col, dia1, dia2)
        return hit_sum

    int solve(self):
        cdef IntList conflict_queens
        cdef int q, destination, row
        cdef IntList queens
        cdef int count

        queens = global_queens[0]
        while 1:
            conflict_queens = IntList()
            for q in queens:
                if self.count_hits(q) == 0:
                    continue
                conflict_queens.append(q)
            if conflict_queens.__len__() == 0:
                return 1

            for q in conflict_queens:
                row = q // self.size
                destination = self.move_queen(row)
                queens[row] = destination

    int move_queen(self, int row):
        cdef lock Scheduler scheduler
        cdef active Generator generator
        cdef int dest

        scheduler = Scheduler()
        generator = activate(consume Generator(
                                        scheduler,
                                        row,
                                        self.size,
                                        self.large))
        generator.run(NULL)
        scheduler.finish()
        del scheduler
        generator_object = consume(generator)
        dest = generator_object.destination()
        return dest

    void display(self):
        cdef cypset[int] set_queens
        cdef int x, row, col
        cdef IntList queens

        queens = global_queens[0]
        if self.size > MAX_DISPLAY:
            return
        set_queens = cypset[int]()
        for i in range(self.size):
            set_queens.add(queens[i])
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
