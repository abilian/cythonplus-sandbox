# golomb sequence

cdef long g(long n) nogil:
    if n == 1:
        return 1
    return g(n - g(g(n - 1))) + 1


cdef list cy_golomb_sequence(long size):
    cdef list lst = []
    cdef long i

    for i in range(1, size+1):
        lst.append((i, g(i)))
    return lst


cpdef golomb_sequence(long size):
    # to permit import from python module
    return cy_golomb_sequence(size)


def main(size=None):
    if not size:
        size = 50
    print(cy_golomb_sequence(int(size)))
