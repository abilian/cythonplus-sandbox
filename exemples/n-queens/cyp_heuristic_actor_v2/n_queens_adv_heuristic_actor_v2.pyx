"""N-queens problem
Heuristic using advanced 1D list of queens positions, v2, cython+ actors
"""
from libc.stdio cimport printf
from libc.time cimport time, difftime, time_t
from libcythonplus.list cimport cyplist
from libcythonplus.set cimport cypset
from scheduler.scheduler cimport BatchMailBox, NullResult, Scheduler


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


cdef cypclass Queen:
    int row
    int col
    int diag1
    int diag2

    __init__(self):
        self.row = 0
        self.col = 0
        self.diag1 = 0
        self.diag2 = 0

    void set_position(self, int row, int col, int large):
        self.row = row
        self.col = col
        self.diag1 = (col + row) % large
        self.diag2 = (col - row) % large

    Queen copy(self):
        cdef Queen cp

        cp = Queen()
        cp.row = self.row
        cp.col = self.col
        cp.diag1 = self.diag1
        cp.diag2 = self.diag2
        return cp

    int is_seen(self, Queen other):
        # if other.row == self.row:  Always test for other rows
        #     return 1
        if other.col == self.col:
            return 1
        if other.diag1 == self.diag1:
            return 1
        if other.diag2 == self.diag2:
            return 1
        return 0

    int coord_1d(self, int board_size):
        cdef int coord

        coord = self.row * board_size + self.col
        return coord


cdef Queen copy_iso_queen(iso Queen iq) nogil:
    cdef Queen q

    q = Queen()
    q.row = iq.row
    q.col = iq.col
    q.diag1 = iq.diag1
    q.diag2 = iq.diag2
    return q


ctypedef cyplist[Queen] QueenList

cdef Rnd rnd
cdef QueenList[1] global_queens
cdef int MAX_DISPLAY = 80
rnd = Rnd()
global_queens[0] = QueenList()


cdef int count_hits(Queen target) nogil:
    cdef int hit_sum
    cdef Queen q
    cdef QueenList queens

    queens = global_queens[0]
    hit_sum = 0
    for i in range(target.row):
        q = queens[i]
        hit_sum += target.is_seen(q)
    for i in range(target.row + 1, <int>queens.__len__()):
        q = queens[i]
        hit_sum += target.is_seen(q)
    return hit_sum


cdef cypclass Recorder activable:
    QueenList storage
    int min_hits

    __init__(self, lock Scheduler scheduler):
        self._active_result_class = NullResult
        self._active_queue_class = consume BatchMailBox(scheduler)
        self.storage = QueenList()
        # hack: we test at storage time we got the minimum hit,
        # so we do not store useless values
        self.min_hits = 2**30

    void store(self, iso Queen q, int hits):
        if hits <= self.min_hits:
            if hits < self.min_hits:
                self.storage.clear()  # erase values too big
                self.min_hits = hits
            self.storage.append(consume q)

    Queen result(self):
        cdef int rnd_idx
        cdef Queen q

        if self.storage.__len__() > 1:
            rnd_idx = rnd(<int>self.storage.__len__())
        else:
            rnd_idx = 0
        q = self.storage[rnd_idx]
        return q


cdef cypclass HitBoard activable:
    iso Queen position
    int size
    int large
    lock Scheduler scheduler
    active Recorder recorder

    __init__(self,
             lock Scheduler scheduler,
             active Recorder recorder,
             iso Queen position
             ):
        self._active_result_class = NullResult
        self._active_queue_class = consume BatchMailBox(scheduler)
        self.recorder = recorder
        self.position = consume position

    void run(self):
        cdef int hits
        cdef Queen q

        q = copy_iso_queen(consume self.position)
        hits = count_hits(q)
        self.recorder.store(NULL, consume q, hits)


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
        cdef Queen position

        for col in range(self.size):
            position = Queen()
            position.set_position(self.row, col, self.large)
            hit_board = activate(consume(
                        HitBoard(
                            self.scheduler,
                            self.recorder,
                            consume position
                            )))
            hit_board.run(NULL)

    Queen destination(self):
        cdef Queen destination

        recorder = consume self.recorder
        destination = consume(recorder.result().copy())
        return destination


cdef cypclass Board:
    int size
    int large

    __init__(self, int size):
        cdef Queen q
        cdef int row
        cdef QueenList queens

        queens = global_queens[0]
        queens.clear()
        self.size = size
        self.large = 2 * size + 1
        # initialize at random result position
        for row in range(size):
            q = Queen()
            q.set_position(row, rnd(size), self.large)
            queens.append(q)

    void solve(self):
        cdef QueenList queens, conflict_queens
        cdef Queen q

        queens = global_queens[0]
        conflict_queens = QueenList()
        while 1:
            conflict_queens.clear()
            for i in range(self.size):
                q = queens[i]
                if count_hits(q) == 0:
                    continue
                conflict_queens.append(q)
            if conflict_queens.__len__() == 0:
                return
            for q in conflict_queens:
                queens[q.row] = self.move_queen(q.row)

    Queen move_queen(self, int row):
        cdef lock Scheduler scheduler
        cdef active Generator generator
        cdef Queen new_position

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
        new_position = consume generator_object.destination()
        return new_position

    void display(self):
        cdef cypset[int] set_queens
        cdef int x, row, col
        cdef QueenList queens
        cdef Queen q

        queens = global_queens[0]
        if self.size > MAX_DISPLAY:
            return
        set_queens = cypset[int]()
        for q in queens:
            set_queens.add(q.coord_1d(self.size))
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
        board.display()  ####
        board.solve()
        board.display()
        t1 = time(NULL)
        dtime = difftime(t1, t0)
        printf("duration for size %d: ~%.0fs\n", size, dtime)
