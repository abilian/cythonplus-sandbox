# distutils: language = c++
"""
Cython+ exemple, cyplist minimal exemple
(using syntax of september 2021)
"""
from libcythonplus.list cimport cyplist
from stdlib.fmt cimport printf


# define a specialized type: list of int
ctypedef cyplist[int] IntList


cdef void demo_cyplist():
    cdef IntList lst
    cdef int count

    lst = IntList()
    with nogil:
        for i in range(4):
            lst.append(<int> i)

        printf("lst.__len__(): %d\n", lst.__len__())

        # no slice:
        # printf("lst[-1]: %d\n", <int>lst[-1])
        # lst2 = lst[1:3]

        lst[0] = 100
        lst[1] += 250
        lst[2] = lst[2] + 100 * lst[3]
        for i in range(lst.__len__()):
            printf("%d: %d  ", i, <int> lst[i])
        printf("\n")

        del lst[3]
        lst = lst * 2
        count = 0
        for value in lst:
            printf("%d: %d  ", count, <int> value)
            count += 1
        printf("\n")

        printf("100 in lst: %d\n", 100 in lst)


def main():
    demo_cyplist()
