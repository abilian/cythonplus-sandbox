"""Cython+ exemple, sort a list (using syntax of march 2022)
"""
from libc.stdio cimport printf
from libcpp.algorithm cimport sort, reverse
from libcythonplus.list cimport cyplist

# define a specialized type: list of int
ctypedef cyplist[int] IntList


cdef void print_list(IntList lst) nogil:
    for i in range(lst.__len__()):
        printf("%d ", <int>lst[i])
    printf("\n")


cdef void sort_list(IntList lst) nogil:
    if lst._active_iterators == 0:
        sort(lst._elements.begin(), lst._elements.end())
    else:
        with gil:
            raise RuntimeError("Modifying a list with active iterators")


cdef void reverse_list(IntList lst) nogil:
    if lst._active_iterators == 0:
        reverse(lst._elements.begin(), lst._elements.end())
    else:
        with gil:
            raise RuntimeError("Modifying a list with active iterators")


cdef void demo_sort():
    cdef IntList lst

    lst = IntList()
    with nogil:
        printf("-------- containers demo list sort / reverse --------\n")

        lst.append(20)
        lst.append(300)
        lst.append(10)
        lst.append(2)
        lst.append(1000)
        lst.append(1)

        printf('original list:\n')
        print_list(lst)

        printf('reverse list in-place:\n')
        reverse_list(lst)
        print_list(lst)

        printf('reverse list in-place:\n')
        reverse_list(lst)
        print_list(lst)

        printf('sort list in-place:\n')
        sort_list(lst)
        print_list(lst)

        printf('reverse list in-place:\n')
        reverse_list(lst)
        print_list(lst)


def main():
    demo_sort()
