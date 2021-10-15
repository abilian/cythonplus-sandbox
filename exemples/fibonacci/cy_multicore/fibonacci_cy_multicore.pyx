from cython.parallel import prange

cdef double fibo(int n) nogil:
    cdef double a, b
    a = 0.0
    b = 1.0
    cdef int i
    for i in range(n):
        a, b = b, a + b
    return a


cdef list fibo_list(int size):
    cdef list results = []
    cdef int i
    cdef double x

    # here, multicore implementation
    for i in prange(size + 1, nogil=True, num_threads=4,
                    schedule='static', chunksize=100):
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
    print_summary(fibo_list(int(size)))
