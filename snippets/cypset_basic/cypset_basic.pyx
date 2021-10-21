# distutils: language = c++
"""
Cython+ exemple, cypset minimal exemple
(using syntax of september 2021)
"""
from libcythonplus.set cimport cypset
from stdlib.string cimport string
from stdlib.fmt cimport printf


# define a specialized type: set of long
ctypedef cypset[long] LongSet


cdef void show_set(LongSet s) nogil:
    for item in s:
        printf("%ld  ", <long> item)
    printf("\n")


cdef void demo_cypset():
    cdef LongSet s1, s2

    s1 = LongSet()
    s2 = LongSet()
    with nogil:
        for i in range(4):
            s1.add(<long> i)
        s2.add(100)
        s2.add(200)

        printf("s1.__len__(): %d\n", s1.__len__())
        show_set(s1)

        s1.add(10)
        s1.add(10)  # add existing
        show_set(s1)

        s1.discard(42)  # discard non existing
        s1.discard(2)
        show_set(s1)

        s1.update(s2)
        show_set(s1)


def main():
    demo_cypset()
