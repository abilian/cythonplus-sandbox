# distutils: language = c++
from libcythonplus.list cimport cyplist

cdef cypclass Fibo:
    int level
    double value

    __init__(self, int level):
        self.level = level
        self.value = 0.0


    void compute(self):
        cdef double a, b, tmp
        a = 0.0
        b = 1.0
        cdef int i
        for i in range(self.level):
            a, b = b, a + b
        self.value = a



ctypedef cyplist[Fibo] Flist


cdef Flist fibo_list(int size) nogil:
    cdef Flist results
    cdef Fibo f
    cdef int i
    cdef double x

    results = Flist()
    for i in range(size+1):
        f = Fibo(i)
        f.compute()
        results.append(f)
    return results



cdef py_fibo_sequence(long size):
    cdef Flist results
    with nogil:
        results = fibo_list(size)
    return [f.value for f in results]


def print_summary(sequence):
    for idx in (0, 1, -1):
        print(f"{idx}: {sequence[idx]:.1f}, ")


def main(size=None):
    if not size:
        size = 1476
    print_summary(py_fibo_sequence(int(size)))
