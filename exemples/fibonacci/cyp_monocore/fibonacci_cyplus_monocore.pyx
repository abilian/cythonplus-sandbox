# distutils: language = c++
# Fibonacci x 100, cythonplus monocore
from libcythonplus.list cimport cyplist


cdef cypclass Fibo:
    int level
    double value

    __init__(self, int level):
        self.level = level
        self.value = 0.0


    void compute(self):
        cdef double a, b
        cdef int i

        a = 0.0
        b = 1.0
        for i in range(self.level):
            a, b = b, a + b
        self.value = a



ctypedef cyplist[Fibo] Flist


cdef Flist fibo_list(int size) nogil:
    cdef Flist results
    cdef Fibo fibo
    cdef int i
    cdef double x

    results = Flist()
    for i in range(size + 1):
        fibo = Fibo(i)
        fibo.compute()
        results.append(fibo)
    return results



cdef py_fibo_sequence(int size):
    cdef Flist results

    with nogil:
        results = fibo_list(size)

    return [fibo.value for fibo in results]



def print_summary(sequence):
    for idx in (0, 1, -1):
        print(f"{idx}: {sequence[idx]:.1f}, ")



def main(size=None):
    if not size:
        size = 1476
    print_summary(py_fibo_sequence(int(size)))



cdef list py_fibo_many(int size, int repeat):
    cdef list many = []

    for i in range(repeat):
        many.append(py_fibo_sequence(size))
    return many



def fibo_many(size=None, repeat=None):
    if not size:
        size = 1476
    if not repeat:
        repeat = 100
    size = int(size)
    repeat = int(repeat)
    return py_fibo_many(size, repeat)
