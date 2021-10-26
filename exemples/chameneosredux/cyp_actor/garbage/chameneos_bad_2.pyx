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


# ctypedef cyplist[active Dragon] DList
ctypedef cyplist[Dragon] DList


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
    Arena arena
    cypdict[int, int] color_matrix
    unsigned long id  # because it is the index of an array
    int color
    int met   # meetings counter
    int same  # errors counter (same id meeting)

    __init__(self,
             lock PersistScheduler scheduler,
             Arena arena,
             cypdict[int, int] color_matrix,
             unsigned long id,
             int color):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.arena = arena
        self.id = id
        self.color = color
        self.met = 0
        self.same = 0


    void meet_with(self, unsigned long id, int color, int meeting_left):
        if id == self.id:
            self.same += 1
        self.met += 1
        self.color = self.color_matrix[self.color * 3 + color]
        if meeting_left > 0:
            # d = activate(self)  # Cannot assign type 'Dragon' to 'iso Dragon'

            # d = activate(consume self)
            # d.wait_meeting(NULL)

            self.wait_meeting()


    void wait_meeting(self):
        with wlocked self.arena:
            self.arena.meet(self.id, self.color)



cdef cypclass Arena:
    DList dragons
    int meetings_left
    int some_dragon_is_waiting
    unsigned long first_id
    int first_color

    # __init__(self, lock PersistScheduler scheduler, DList dragons, int meetings_left):
    __init__(self, DList dragons, int meetings_left):
        # self._active_result_class = NullResult
        # self._active_queue_class = consume SequentialMailBox(scheduler)
        self.dragons = dragons
        self.meetings_left = meetings_left
        self.dragons = dragons
        self.some_dragon_is_waiting = 0
        self.first_id = 0
        self.first_color = 0


    void meet(self, unsigned long id, int color):
        self.meetings_left -= 1
        if self.some_dragon_is_waiting == 0:
            self.first_id = id
            self.first_color = color
            self.some_dragon_is_waiting = 1
        else:
            d1 = self.dragons[self.first_id]
            # d1 = activate(self.dragons[self.first_id])  # Cannot assign type 'active Dragon' to 'iso Dragon'
            # d1 = activate(consume self.dragons[self.first_id])  # not possible

            # d1.meet_with(NULL, id, color, meetings_left)
            d1.meet_with(id, color, meetings_left)

            d2 = self.dragons[id]
            # d2.meet_with(NULL, self.first_id, self.first_color, meetings_left)
            d2.meet_with(self.first_id, self.first_color, meetings_left)




# def report(input_zoo, met, same):
#     print("zoo:", " ".join(input_zoo))
#     for idx in range(len(input_zoo)):
#         print(f"{idx:2}: met = {met[idx]:<6} same = {same[idx]:<6}")
#     print("total met:", sum(met))
#     print()
#



cdef void let_them_meet(meetings_left, input_zoo):
    cdef lock PersistScheduler scheduler
    cdef Arena arena
    cdef DList dragons
    cdef unsigned long i
    cdef cypdict[int, int] color_matrix

    color_matrix = cypdict[int, int]()
    for k, v in COMPLEMENT_MUL.items():
        color_matrix[k] = v
    scheduler = PersistScheduler()
    dragons = DList()
    arena = Arena(dragons, meetings_left)  # no 'lock' keyword ?
    # convert string colors to Dragon using color as int
    i = 0
    for color in input_zoo:
        # dragons.append(activate(consume Dragon(
        dragons.append(Dragon(
            scheduler,
            arena,
            color_matrix,
            i,
            COLORS_TO_I[color])
        )
        i += 1
    # initiate
    for d in dragons:
        # da = activate(consume d) #  Compiler crash in AnalyseExpressionsTransform
        da.wait_meeting(NULL)



def main(nb=None):
    # if nb == "check":
    #     return check_complement()
    if not nb:
        nb = 10000
    let_them_meet(int(nb), ZOO_3)
    # let_them_meet(int(nb), ZOO_10)
