"""Cython+ exemple, containers (using syntax of march 2022)
"""
from libc.stdio cimport printf
from libcythonplus.dict cimport cypdict
from libcythonplus.list cimport cyplist

from .stdlib.string cimport Str


cdef cypclass Containers:
    cyplist[int] some_list
    cypdict[int, float] some_dict
    cypdict[Str, int] another_dict

    __init__(self):
        self.some_list = cyplist[int]()
        self.some_dict = cypdict[int, float]()
        self.another_dict = cypdict[Str, int]()

    void load_values(self):
        self.some_list.append(1)
        self.some_list.append(20)
        self.some_list.append(30)
        self.some_dict[1] = 0.1234
        self.some_dict[20] = 3.14
        self.another_dict[Str("a")] = 1
        self.another_dict[Str("foo")] = self.some_list[1]

    void show_content(self):
        printf("-------- containers quick example, version 1 --------\n")
        printf("some_list:\n")
        for i in self.some_list:
            printf("  %d ", i)
        printf("\n")

        printf("some_dict:\n")
        for item1 in self.some_dict.items():
            printf("  %d: %f\n", <int>item1.first, <float>item1.second)

        printf("another_dict:\n")
        for item2 in self.another_dict.items():
            printf("  %s: %d\n", (<Str>item2.first).bytes(), <int>item2.second)


def main():
    cdef Containers c

    with nogil:
        c = Containers()
        c.load_values()
        c.show_content()
