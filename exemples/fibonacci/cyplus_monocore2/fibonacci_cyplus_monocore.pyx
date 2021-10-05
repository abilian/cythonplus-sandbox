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
            tmp = a
            a = b
            b = tmp + b
        self.value = a



ctypedef cyplist[Fibo] Flist


cdef Flist fibo_list(int size) nogil:
    cdef Flist results
    cdef Fibo f
    cdef int i
    cdef double x
    results = Flist()
    # with nogil:
    for i in range(size):
        f = Fibo(i)
        f.compute()
        results.append(f)
    return results


def main():
    py_results = [(f.level, f.value) for f in fibo_list(1477)]
    print(py_results[-10:])
