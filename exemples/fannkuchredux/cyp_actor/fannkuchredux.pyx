# distutils: language = c++
# fannkuchredux, cythonplus, wip
#
# taken from fannkuchredux.pyx in:
# " The Computer Language Benchmarks Game
#   http://benchmarksgame.alioth.debian.org/
#
#   contributed by Jacek Pliszka
#   algorithm is based on Java 6 source code by Oleg Mazurov
#   source is based on Miroslav Rubanets' C++ submission.
#   converted to python by Ian P. Cooke
#   converted to generators by Jacek Pliszka
# "

import sys
import math
from multiprocessing import cpu_count, Pool

cdef int MAX_PROBLEM_SIZE, MAX_CPU_LIMIT

MAX_PROBLEM_SIZE = 12
MAX_CPU_LIMIT = 4


def PermutationGenerator(int length, int idx):
    cdef int i, d

    count = [0] * length
    perm = list(range(length))

    for i in range(length - 1, 0, -1):
        d, idx = divmod(idx, math.factorial(i))
        count[i] = d
        perm[:i+1-d], perm[i+1-d:i+1] = perm[d:i+1], perm[:d]  # rotate

    yield perm  # first permutation

    while 1:
        perm[0], perm[1] = perm[1], perm[0]   # rotate
        count[1] += 1
        i = 1
        while count[i] > i:
            count[i] = 0
            i += 1
            if i >= length:
                break
            count[i] += 1
            perm[:i], perm[i] = perm[1:i+1], perm[0]  # rotate

        yield perm


def task_body(parms):
    cdef int maxflips, checksum

    g = PermutationGenerator(parms[0], parms[1])

    maxflips = 0
    checksum = 0
    for i in range(parms[1], parms[2]):
        data = list(g.next() if sys.version_info[0] < 3 else g.__next__())
        f = data[0]
        if f > 0:
            flips = 0
            while f:
                data[:f+1] = data[f::-1]  # reverse
                flips += 1
                f = data[0]
            maxflips = max(maxflips, flips)
            checksum += -flips if i % 2 else flips

    return maxflips, checksum

usage = """usage fannkuchredux number
number has to be in range [3-12]\n"""


def main_fk(length):
    cdef int nb_cpu, index_max, index_step

    nb_cpu = min(cpu_count(), MAX_CPU_LIMIT)

    index_max = math.factorial(length)
    index_step = (index_max + nb_cpu - 1) // nb_cpu

    parms = [(length, i, i + index_step) for i in range(0, index_max, index_step)]

    processors = Pool(processes=nb_cpu)
    res = list(zip(*processors.map(task_body, parms)))

    processors.close()
    processors.join()
    processors.terminate()

    print("%d\nPfannkuchen(%d) = %d" % (sum(res[1]), length, max(res[0])))


def main(length=None):
    if not length:
        length = 10
    main_fk(length)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(usage)
    length = int(sys.argv[1])
    if length < 3 or length > MAX_PROBLEM_SIZE:
        print(usage)
    main_fk(length)
