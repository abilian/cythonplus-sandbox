# distutils: language = c++
# Dragoneneos, cythonplus actor
# Code adapted from:
#   The Computer Language Benchmarks Game
#   http://benchmarksgame.alioth.debian.org/
#   contributed by Daniel Nanz 2008-04-10

from libcythonplus.dict cimport cypdict
from libcythonplus.list cimport cyplist
from scheduler.persistscheduler cimport SequentialMailBox, NullResult, PersistScheduler

from stdlib.fmt cimport printf

# ctypedef cyplist[Dragon] DList


COLORS = ("blue", "red", "yellow")  # strings are faster than constant=string
COLORS_TO_I = {
    "blue": 1,
    "red": 2,
    "yellow": 3,
}
I_TO_COLOR = {
    1: "blue",
    2: "red",
    3: "yellow",
}

# Defined in see in cypclass ColorMatrix:
# COMPLEMENT_MUL = {
#     4: 1,
#     5: 3,
#     6: 2,
#     7: 3,
#     8: 2,
#     9: 1,
#     10: 2,
#     11: 1,
#     12: 3,
# }

ZOO_3 = ["blue", "red", "yellow"]
ZOO_10 = [
    "blue",
    "red",
    "yellow",
    "red",
    "yellow",
    "blue",
    "red",
    "yellow",
    "red",
    "blue",
]


cdef cypclass Pair:
    int total_met
    int total_self_met

    __init__(self, int total_met, int total_self_met):
        self.total_met = total_met
        self.total_self_met = total_self_met


ctypedef cypdict[unsigned long, Pair] record_t


cdef cypclass Recorder activable:
    record_t storage

    __init__(self, lock PersistScheduler scheduler):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.storage = record_t()


    void store(self, unsigned long id, int met, int self_met):
        cdef Pair pair

        pair = Pair(met, self_met)
        self.storage[id] = pair


    record_t content(self):
        return self.storage



# Most easy way of duplicating a dict is to make it in a class ?
cdef cypclass ColorMatrix:
    cypdict[int, int] matrix

    __init__(self):
        self.matrix = cypdict[int, int]()
        self.matrix[4] = 1
        self.matrix[5] = 3
        self.matrix[6] = 2
        self.matrix[7] = 3
        self.matrix[8] = 2
        self.matrix[9] = 1
        self.matrix[10] = 2
        self.matrix[11] = 1
        self.matrix[12] = 3



cdef cypclass Dragon activable:
    lock PersistScheduler scheduler
    lock Arena arena
    active Recorder recorder
    iso ColorMatrix color_matrix
    unsigned long id  # because it is the index of an array
    int color
    int met   # meetings counter
    int same  # errors counter (same id meeting)

    __init__(self,
             lock PersistScheduler scheduler,
             lock Arena arena,
             active Recorder recorder,
             iso ColorMatrix color_matrix,
             unsigned long id,
             int color):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.scheduler = scheduler
        self.arena = arena
        self.recorder = recorder
        self.color_matrix = consume color_matrix
        self.id = id
        self.color = color
        self.met = 0
        self.same = 0


    void set_state(self, int met, int same):
        self.met = met
        self.same = same


    Dragon clone(self):
        cdef Dragon clone_dragon

        clone_dragon = Dragon(
            self.scheduler,
            self.arena,
            self.recorder,
            consume ColorMatrix(),
            self.id,
            self.color
        )
        clone_dragon.set_state(self.met, self.same)
        return clone_dragon


    void meet_with(self, unsigned long id, int color):
        # printf("meet_with %ld : %ld \n", self.id, id)
        if id == self.id:
            self.same += 1
        self.met += 1
        self.color = self.color_matrix.matrix[self.color * 3 + color]
        self.wait_meeting()
        # clone_dragon = activate(consume self.clone())
        # clone_dragon.wait_meeting(NULL, clone_dragon)


    void report_exit(self):
        # send statistics to report recorder
        self.recorder.store(NULL, self.id, self.met, self.same)
        # end of cycle for this dragon and its clones
        # printf("End of cycle for %d\n", self.id)
        # printf("%d: %d %d\n", self.id, self.met, self.same)


    void wait_meeting(self):
        # printf("wait_meeting start for %ld %s\n", self.id, aself)
        with wlocked self.arena:
            self.arena.enter_arena(consume self.clone(), self.id, self.color)



cdef cypclass Arena:
    # lock PersistScheduler scheduler
    # cypdict[int, int] color_matrix
    # DList dragons
    int meetings_left
    unsigned long first_id
    int first_color
    active Dragon first_dragon

    __init__(self, int meetings_left):
        self.meetings_left = meetings_left
        self.first_dragon = NULL


    void enter_arena(self,
              iso Dragon candidate,
              unsigned long candidate_id,
              int candidate_color):
        cdef active Dragon d1, d2

        d2 = activate(consume candidate)
        # printf("enter_arena (%d left) %ld %s\n",
        #        self.meetings_left, candidate_id, candidate)
        if self.meetings_left <= 0:
            # printf("report and exit for candidate %d\n", candidate_id)
            d2.report_exit(NULL)
            del d2
        elif self.first_dragon:
            self.meetings_left -= 1
            # printf("encounter %ld %ld\n", self.first_id, candidate_id)
            d1 = activate(consume self.first_dragon)
            d1.meet_with(NULL, candidate_id, candidate_color)
            d2.meet_with(NULL, self.first_id, self.first_color)
            del d1
            del d2
            # printf("    end encounter %ld %ld\n", self.first_id, candidate_id)
        else:
            # printf("first candidate %ld\n", candidate_id)
            self.first_dragon = d2
            self.first_id = candidate_id
            self.first_color = candidate_color



cdef void let_them_meet(int meetings_left, list input_zoo):
    cdef lock PersistScheduler scheduler
    cdef lock Arena arena
    cdef int i
    cdef active Dragon dragon
    cdef unsigned long id
    cdef cypdict[int, int] color_matrix
    cdef active Recorder recorder
    cdef Recorder consumed_recorder
    cdef cyplist[int] int_zoo

    # convert string colors to Dragon using color as int
    int_zoo = cyplist[int]()
    for c in input_zoo:
        int_zoo.append(COLORS_TO_I[c])

    with nogil:
        scheduler = PersistScheduler()
        arena = consume Arena(meetings_left)
        recorder = activate (consume Recorder(scheduler))

        id = 0
        for i in int_zoo:
            dragon = activate(consume Dragon(
                scheduler,
                arena,
                recorder,
                consume ColorMatrix(),
                id,
                i
            ))
            dragon.wait_meeting(NULL)
            # printf("dragon %d started\n", id)
            del dragon
            id += 1

        scheduler.finish()
        del scheduler
        consumed_recorder = consume(recorder)
        results = consumed_recorder.content()

    # to use exactly the same report function
    met = []
    self_met = []
    id = 0
    for i in range(len(input_zoo)):
        r = results[id]
        met.append(r.total_met)
        self_met.append(r.total_self_met)
        id += 1

    report(input_zoo, met, self_met)



def report(input_zoo, met, self_met):
    print("zoo:", " ".join(input_zoo))
    for idx in range(len(input_zoo)):
        print(f"{idx:2}: met = {met[idx]:<6} self_met = {self_met[idx]:<6}")
    print("total met:", sum(met))
    print()


def main(nb=None):
    if not nb:
        nb = 10000
    let_them_meet(int(nb), ZOO_3)
    let_them_meet(int(nb), ZOO_10)
