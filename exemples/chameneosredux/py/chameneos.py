#!/usr/bin/env python
# Code adapted from:
#   The Computer Language Benchmarks Game
#   http://benchmarksgame.alioth.debian.org/
#   contributed by Daniel Nanz 2008-04-10

import sys
import _thread

# import time

COLORS = ("blue", "red", "yellow")  # strings are faster than constant=string
COMPLEMENT = {
    ("blue", "blue"): "blue",
    ("blue", "red"): "yellow",
    ("blue", "yellow"): "red",
    ("red", "blue"): "yellow",
    ("red", "red"): "red",
    ("red", "yellow"): "blue",
    ("yellow", "blue"): "red",
    ("yellow", "red"): "blue",
    ("yellow", "yellow"): "yellow",
}


def check_complement():
    for c1 in COLORS:
        for c2 in COLORS:
            print(f"{c1} + {c2} -> {COMPLEMENT[(c1,c2)]}")
    print()


def report(input_zoo, met, self_met):
    print("zoo:", " ".join(input_zoo))
    for idx in range(len(input_zoo)):
        print(f"{idx:2}: met = {met[idx]:<6} self_met = {self_met[idx]:<6}")
    print("total met:", sum(met))
    print()


def creature(my_id, venue, my_lock_acquire, in_lock_acquire, out_lock_release):
    while True:
        my_lock_acquire()  # only proceed if not already at meeting place
        in_lock_acquire()  # only proceed when holding in_lock
        venue[0] = my_id  # register at meeting place
        out_lock_release()  # signal "registration ok"


def let_them_meet(meetings_left, input_zoo):
    allocate = _thread.allocate_lock
    # prepare
    nb_beast = len(input_zoo)
    venue = [-1]
    met = [0] * nb_beast
    self_met = [0] * nb_beast
    colors = input_zoo[:]

    in_lock = allocate()
    in_lock_acquire = in_lock.acquire  # function aliases
    in_lock_release = in_lock.release  # (minor performance gain)
    in_lock_acquire()
    out_lock = allocate()
    out_lock_release = out_lock.release
    out_lock_acquire = out_lock.acquire
    out_lock_acquire()
    locks = [allocate() for c in input_zoo]

    # let creatures wild
    for idx in range(nb_beast):
        args = (idx, venue, locks[idx].acquire, in_lock_acquire, out_lock_release)
        new = _thread.start_new_thread(creature, args)
    # time.sleep(0.05)  # to reduce work-load imbalance

    in_lock_release()  # signal "meeting_place open for registration"
    out_lock_acquire()  # only proceed with a "registration ok" signal
    id1 = venue[0]
    while meetings_left > 0:
        in_lock_release()
        out_lock_acquire()
        id2 = venue[0]
        if id1 != id2:
            new_color = COMPLEMENT[(colors[id1], colors[id2])]
            colors[id1] = new_color
            colors[id2] = new_color
            met[id1] += 1
            met[id2] += 1
        else:
            self_met[id1] += 1
            met[id1] += 1
        meetings_left -= 1
        locks[id1].release()  # signal "you were kicked from meeting place"
        id1 = id2
    report(input_zoo, met, self_met)


def chameneosiate(n):
    let_them_meet(n, ["blue", "red", "yellow"])
    let_them_meet(
        n,
        [
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
        ],
    )


def main(nb=None):
    if nb == "check":
        return check_complement()
    if not nb:
        nb = 100_000
    chameneosiate(int(nb))


if __name__ == "__main__":
    if len(sys.argv) > 1:
        main(sys.argv[1])
    else:
        main()
