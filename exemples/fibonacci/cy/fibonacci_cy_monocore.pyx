
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
    # here, no multicore implementation
    for i in range(size):
        results.append((i, fibo(i)))
    return results


def main():
    print(fibo_list(1477)[-10:])
