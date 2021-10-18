# distutils: language = c++
# golomb sequence
# another cyplus implementation, faster ?
from libcythonplus.list cimport cyplist


cdef long g(long n) nogil:
    """Return the value of position n of the Golomb sequence (recursice function).
    """
    if n == 1:
        return 1
    return g(n - g(g(n - 1))) + 1


cdef cypclass Golomb:
    long rank
    long value

    __init__(self, long rank):
        self.rank = rank
        self.value = g(self.rank)


ctypedef cyplist[long] Longlist


cdef Longlist golomb_sequence(long size) nogil:
    cdef Longlist lst

    lst = Longlist()
    for i in range(1, size + 1):
        lst.append(Golomb(i).value)
    return lst


cpdef py_golomb_sequence(long size):
    cdef Longlist glist

    return list(enumerate([0]+[i for i in golomb_sequence(size)]))[1:]


def main(size=None):
    if not size:
        size = 50
    print(py_golomb_sequence(int(size)))
