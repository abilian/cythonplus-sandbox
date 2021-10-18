# distutils: language = c++
# golomb sequence
# cythonplus monocore, implementation with internal method

from libcythonplus.list cimport cyplist


cdef cypclass Golomb:
    long rank
    long value

    __init__(self, long rank):
        self.rank = rank
        self.value = 0
        self.compute()  # would prefer to not compute directly in init

    long gpos(self, long n):  # better with external function ?
        if n == 1:
            return 1
        return self.gpos(n - self.gpos(self.gpos(n - 1))) + 1

    void compute(self):
        self.value = self.gpos(self.rank)



ctypedef cyplist[Golomb] Glist


cdef Glist golomb_sequence(long size) nogil:
    cdef Glist lst

    lst = Glist()
    for i in range(1, size+1):
        lst.append(Golomb(i))
    return lst


cpdef py_golomb_sequence(long size):
    cdef Glist glist

    glist = golomb_sequence(size)
    sequence = [(g.rank, g.value) for g in glist]
    return sequence


def main(size=None):
    if not size:
        size = 50
    print(py_golomb_sequence(int(size)))
