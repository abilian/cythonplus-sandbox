from cython.parallel import prange

cdef double fibo(int n) nogil:
    cdef double a, b, tmp
    a = 0.0
    b = 1.0
    cdef int i
    for i in range(n):
        tmp = a
        a = b
        b = tmp + b
    return a


cdef list fibo_list(int size):
    cdef list results = []
    cdef int i
    cdef double x
    # here, multicore implementation
    for i in prange(size, nogil=True, num_threads=4, schedule='static', chunksize=100):
        x = fibo(i)
        with gil:
            results.append((i, x))
    return results


def main():
    print(sorted(fibo_list(1477))[-10:])
