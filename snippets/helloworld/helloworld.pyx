# distutils: language = c++
"""
Cython+ exemple, helloworld
(using syntax of september 2021)
"""
from stdlib.string cimport string
from stdlib.fmt cimport printf


cdef cypclass HelloWorld:
    string message

    __init__(self):
        self.message = string("Hello World\n")

    void print_message(self):
        printf(self.message)


def main():
    cdef HelloWorld hello
    with nogil:
        # the Helloworld instance and print_message() method are outside the scope
        # of the python GIL
        hello = HelloWorld()
        hello.print_message()
