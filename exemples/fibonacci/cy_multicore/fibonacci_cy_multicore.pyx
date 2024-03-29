# Fibonacci x 100, cython multicore using prange

import os
from cython.parallel import prange


cdef double fibo(int n) nogil:
    cdef double a, b
    cdef int i

    a = 0.0
    b = 1.0
    for i in range(n):
        a, b = b, a + b
    return a


cdef list fibo_list(int size, int cpus):
    cdef list results = []
    cdef int i
    cdef double x

    # multicore implementation using prange
    for i in prange(size + 1, nogil=True, num_threads=cpus,
                    schedule='static', chunksize=200):
        x = fibo(i)
        with gil:
            results.append((i, x))
    return [r[1] for r in sorted(results)]


def print_summary(sequence):
    for idx in (0, 1, -1):
        print(f"{idx}: {sequence[idx]:.1f}, ")


def main(size=None):
    if not size:
        size = 1476
    cpus = os.cpu_count()
    print_summary(fibo_list(int(size), cpus))


cdef list cy_fibo_many(int size, int repeat):
    cdef list many = []
    cdef int cpus = os.cpu_count()
    cdef int i

    for i in range(repeat):
        many.append(fibo_list(size, cpus))
    return many


def fibo_many(size=None, repeat=None):
    if not size:
        size = 1476
    if not repeat:
        repeat = 100
    size = int(size)
    repeat = int(repeat)
    return cy_fibo_many(size, repeat)
