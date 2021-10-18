# golomb sequence
# cython multicore, using prange
import os
from cython.parallel import prange



cdef long gpos(long n) nogil:
    if n == 1:
        return 1
    return gpos(n - gpos(gpos(n - 1))) + 1


cdef list cy_golomb_sequence(long size):
    cdef list lst = []
    cdef long i, g
    cdef int cpus = os.cpu_count()

    for i in prange(1, size + 1, nogil=True, num_threads=cpus,
                    schedule='static', chunksize=5):
        g = gpos(i)
        with gil:
            lst.append((i, g))
    return lst


cpdef golomb_sequence(long size):
    # to permit import from python module
    return cy_golomb_sequence(size)


def main(size=None):
    if not size:
        size = 50
    print(cy_golomb_sequence(int(size)))
