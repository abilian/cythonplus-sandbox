# distutils: language = c++
# Q&D min, max and sum of a cyplist
from libcythonplus.list cimport cyplist
from stdlib.fmt cimport printf


# define a specialized type: list of int
ctypedef cyplist[int] IntList


cdef void print_list(IntList lst) nogil:
    for i in range(lst.__len__()):
        printf("%d ", <int> lst[i])
    printf("\n")


cdef int min_list(IntList lst) nogil:
    cdef int m
    if lst.__len__() == 0:
        with gil:
            raise ValueError("min() arg is an empty sequence")
    m = lst[0]
    for e in lst:
        m = min(m, e)
    return m


cdef int max_list(IntList lst) nogil:
    cdef int m
    if lst.__len__() == 0:
        with gil:
            raise ValueError("max() arg is an empty sequence")
    m = lst[0]
    for e in lst:
        m = max(m, e)
    return m


cdef int sum_list(IntList lst) nogil:
    cdef int s, e
    s = 0
    for e in lst:
        s += e
    return s


cdef void demo():
    cdef IntList lst
    cdef int i

    lst = IntList()
    with nogil:
        lst.append(4)
        lst.append(20)
        lst.append(10)
        lst.append(2)
        lst.append(1)

        printf('original list:\n')
        print_list(lst)

        printf('min:\n')
        printf("%d\n", min_list(lst))

        printf('max:\n')
        printf("%d\n", max_list(lst))

        printf('sum:\n')
        printf("%d\n", sum_list(lst))


def main():
    demo()
