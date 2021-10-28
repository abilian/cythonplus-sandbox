# distutils: language = c++
# div and mod operators
from stdlib.fmt cimport printf


cdef void demo():
    cdef int a, b

    with nogil:
        a = 10
        b = 3
        printf("nogil integer division and modulo:\n")
        printf("%d // %d\n%d\n", a, b, a // b)
        printf("%d %% %d\n%d\n", a, b, a % b)


def main():
    demo()
