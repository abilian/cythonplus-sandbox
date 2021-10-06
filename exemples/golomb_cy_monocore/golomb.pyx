# golomb sequence

cdef long g(long n) nogil:
    if n == 1:
        return 1
    return g(n - g(g(n - 1))) + 1


cdef list golomb_sequence(long size):
    cdef list lst = []
    cdef long i

    for i in range(1, size+1):
        lst.append((i, g(i)))
    return lst


def main():
    print(golomb_sequence(50))
