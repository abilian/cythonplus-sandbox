#!/usr/bin/env python
#
# taken from: fannkuchredux-6.py in:
#   "  The Computer Language Benchmarks Game
#      http://benchmarksgame.alioth.debian.org/
#      contributed by Isaac Gouy
#      converted to Java by Oleg Mazurov
#      converted to Python by Buck Golemon
#      modified by Justin Peel
#  "
# fannkuchredux, monocore, cython using python syntax
import cython


def fannkuch(n: cython.int) -> cython.int:
    cython.int: maxFlipsCount
    cython.bint: permSign
    cython.int: checksum
    cython.list: perm0
    cython.list: perm1
    cython.list: count
    cython.int: nm
    cython.int: k
    cython.int: flipsCount
    cython.int: kk
    cython.int: r

    permSign = True
    maxFlipsCount = 0
    checksum = 0

    perm1 = list(range(n))
    count = perm1[:]
    rxrange = range(2, n - 1)
    nm = n - 1
    while 1:
        k = perm1[0]
        if k:
            perm = perm1[:]
            flipsCount = 1
            kk = perm[k]
            while kk:
                perm[: k + 1] = perm[k::-1]
                flipsCount += 1
                k = kk
                kk = perm[kk]
            if maxFlipsCount < flipsCount:
                maxFlipsCount = flipsCount
            checksum += flipsCount if permSign else -flipsCount

        # Use incremental change to generate another permutation
        if permSign:
            perm1[0], perm1[1] = perm1[1], perm1[0]
            permSign = False
        else:
            perm1[1], perm1[2] = perm1[2], perm1[1]
            permSign = True
            for r in rxrange:
                if count[r]:
                    break
                count[r] = r
                perm0 = perm1[0]
                perm1[: r + 1] = perm1[1 : r + 2]
                perm1[r + 1] = perm0
            else:
                r = nm
                if not count[r]:
                    print(checksum)
                    return maxFlipsCount
            count[r] -= 1


def main(n=None):
    if not n:
        n = 11
    print(("Pfannkuchen(%i) = %i" % (n, fannkuch(n))))


if __name__ == "__main__":
    from sys import argv

    main(int(argv[1]))
