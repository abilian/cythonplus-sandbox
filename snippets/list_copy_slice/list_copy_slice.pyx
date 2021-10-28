# distutils: language = c++
# quick implementation of basic copy slice
from libcythonplus.list cimport cyplist
from libcpp.algorithm cimport copy
from stdlib.fmt cimport printf


# define a specialized type: list of int
ctypedef cyplist[int] IntList


cdef void print_list(IntList lst) nogil:
    for i in range(lst.__len__()):
        printf("%d ", <int> lst[i])
    printf("\n")


cdef IntList copy_slice(IntList lst, size_t start, size_t end) nogil:
    cdef IntList result = IntList()

    if lst._active_iterators == 0:
        for i in range(start, end):
            result._elements.push_back(lst[i])
        return result
    else:
        with gil:
            raise RuntimeError("Modifying a list with active iterators")


cdef IntList copy_slice_from(IntList lst, size_t start) nogil:  # size_type
    return copy_slice(lst, start, lst._elements.size())


cdef IntList copy_slice_to(IntList lst, size_t end) nogil:  # size_type
    return copy_slice(lst, 0, end)


cdef void demo_slice():
    lst1 = IntList()
    lst2 = IntList()
    with nogil:
        lst1.append(0)
        lst1.append(1)
        lst1.append(2)
        lst1.append(3)
        lst1.append(4)
        lst1.append(5)

        printf('original list:\n')
        print_list(lst1)

        printf('copy slice [1:3] in a new list:\n')
        lst2 = copy_slice(lst1, 1, 3)
        print_list(lst2)

        printf('copy slice [:4] in a new list:\n')
        lst2 = copy_slice_to(lst1, 4)
        print_list(lst2)

        printf('copy slice [4:] in a new list:\n')
        lst2 = copy_slice_from(lst1, 4)
        print_list(lst2)


def main():
    demo_slice()
