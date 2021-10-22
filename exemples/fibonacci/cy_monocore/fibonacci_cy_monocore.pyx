# Fibonacci x 100, cython monocore

cdef double fibo(int n) nogil:
    cdef double a, b
    cdef int i

    a = 0.0
    b = 1.0
    for i in range(n):
        a, b = b, a + b
    return a


cdef list fibo_list(int size):
    cdef list results = []
    cdef int i
    cdef double x

    # monocore implementation
    for i in range(size + 1):
        results.append(fibo(i))
    return results


def print_summary(sequence):
    for idx in (0, 1, -1):
        print(f"{idx}: {sequence[idx]:.1f}, ")


def main(size=None):
    if not size:
        size = 1476
    print_summary(fibo_list(int(size)))


cdef list cy_fibo_many(int size, int repeat):
    cdef list many = []

    for i in range(repeat):
        many.append(fibo_list(size))
    return many


def fibo_many(size=None, repeat=None):
    if not size:
        size = 1476
    if not repeat:
        repeat = 100
    size = int(size)
    repeat = int(repeat)
    return cy_fibo_many(size, repeat)
