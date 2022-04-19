"""Cython+ exemple, helloworld (using syntax of march 2022)
"""
# cython import:
from libc.stdio cimport printf

# local cython+ import:
from helloworld.stdlib.string cimport Str


cdef cypclass HelloWorld:
    Str message

    __init__(self):
        self.message = Str("Hello World!")

    void print_message(self):
        printf("%s\n", self.message.bytes())


def main():
    cdef HelloWorld hello

    with nogil:
        hello = HelloWorld()
        hello.print_message()
