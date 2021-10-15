# distutils: language = c++

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



cdef list fibo_list(int size):
    cdef list results = []
    cdef Fibo f
    cdef int i
    cdef double x
    for i in range(size):
        f = Fibo(i)
        f.compute()
        results.append((i, f.value))
    return results


def main():
    print(fibo_list(1477)[-10:])
