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
COMPLEMENT_MUL = {
    4: 1,
    5: 3,
    6: 2,
    7: 3,
    8: 2,
    9: 1,
    10: 2,
    11: 1,
    12: 3,
}
# COMPLEMENT = {
#     ("blue", "blue"): "blue",
#     ("blue", "red"): "yellow",
#     ("blue", "yellow"): "red",
#     ("red", "blue"): "yellow",
#     ("red", "red"): "red",
#     ("red", "yellow"): "blue",
#     ("yellow", "blue"): "red",
#     ("yellow", "red"): "blue",
#     ("yellow", "yellow"): "yellow",
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


# def check_complement():
#     for c1 in COLORS:
#         for c2 in COLORS:
#             print(f"{c1} + {c2} -> {COMPLEMENT[(c1,c2)]}")
#     print()



cdef cypclass Dragon activable:
    lock PersistScheduler scheduler
    lock Arena arena
    iso cypdict[int, int] color_matrix
    unsigned long id  # because it is the index of an array
    int color
    int met   # meetings counter
    int same  # errors counter (same id meeting)


    __init__(self,
             lock PersistScheduler scheduler,
             lock Arena arena,
             iso cypdict[int, int] color_matrix,
             unsigned long id,
             int color):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.scheduler = scheduler
        self.arena = arena
        self.color_matrix = consume color_matrix
        self.id = id
        self.color = color
        self.met = 0
        self.same = 0


    void meet_with(self, active Dragon aself, unsigned long id, int color, int meetings_left):
        printf("meet_with %ld : %ld (%d)\n", self.id, id, meetings_left)
        if id == self.id:
            self.same += 1
        self.met += 1
        self.color = self.color_matrix[self.color * 3 + color]
        if meetings_left > 0:
            # a_aself = activate(consume aself)
            # a_aself.wait_meeting(NULL, a_aself)
            aself.wait_meeting(NULL, aself)


    void wait_meeting(self, active Dragon aself):
        printf("wait_meeting start for %ld %s\n", self.id, aself)
        with wlocked self.arena:
            self.arena.enter_arena(aself, self.id, self.color)




cdef cypclass Arena:
    # lock PersistScheduler scheduler
    # cypdict[int, int] color_matrix
    # DList dragons
    int meetings_left
    int some_dragon_is_waiting
    unsigned long first_id
    int first_color
    active Dragon first_dragon, d1, d2

    __init__(self, int meetings_left):
        self.meetings_left = meetings_left
        self.some_dragon_is_waiting = 0


    void enter_arena(self,
              active Dragon candidate,
              unsigned long candidate_id,
              int candidate_color):
        printf("enter_arena (%d left) %ld %s\n",
                self.meetings_left, candidate_id, candidate)
        if self.some_dragon_is_waiting == 1:
            self.meetings_left -= 1
            printf("encounter %ld %ld\n", self.first_id, candidate_id)
            # d1 = activate(consume self.first_dragon)
            d1 = self.first_dragon
            printf("    d1 %s\n", d1)
            # d2 = activate(consume candidate)
            d2 = candidate
            printf("    d2 %s\n", d2)
            d1.meet_with(NULL, d1, candidate_id, candidate_color, self.meetings_left)
            d2.meet_with(NULL, d2, self.first_id, self.first_color, self.meetings_left)
            self.some_dragon_is_waiting = 0
            printf("    end encounter %ld %ld\n", self.first_id, candidate_id)


        else:
            printf("first candidate %ld %s\n", candidate_id, candidate)
            self.first_dragon = candidate
            self.first_id = candidate_id
            self.first_color = candidate_color
            self.some_dragon_is_waiting = 1


# def report(input_zoo, met, same):
#     print("zoo:", " ".join(input_zoo))
#     for idx in range(len(input_zoo)):
#         print(f"{idx:2}: met = {met[idx]:<6} same = {same[idx]:<6}")
#     print("total met:", sum(met))
#     print()
#

cdef cypdict[int, int] duplicate_color_matrix():
    color_matrix = cypdict[int, int]()
    for k, v in COMPLEMENT_MUL.items():
        color_matrix[k] = v
    return color_matrix


cdef void let_them_meet(meetings_left, input_zoo):
    cdef lock PersistScheduler scheduler
    cdef lock Arena arena
    # cdef DList dragons
    cdef Dragon dragon
    cdef unsigned long id
    cdef cypdict[int, int] color_matrix

    scheduler = PersistScheduler()
    arena = consume Arena(meetings_left)
    # dragons = DList()

    # convert string colors to Dragon using color as int
    id = 0
    for color in input_zoo:
        dragon = Dragon(
            scheduler,
            arena,
            consume duplicate_color_matrix(),
            id,
            COLORS_TO_I[color]
        )
        candidate = activate(consume dragon)
        candidate.wait_meeting(NULL, candidate)
        id += 1



def main(nb=None):
    # if nb == "check":
    #     return check_complement()
    if not nb:
        nb = 10000
    let_them_meet(int(nb), ZOO_3)
    # let_them_meet(int(nb), ZOO_10)
