# distutils: language = c++
"""
Cython+ experiment with strings (and list): loading, printing,...
(using syntax of november 2021)
"""
from stdlib.string cimport Str
from stdlib.fmt cimport printf, sprintf

from libcythonplus.list cimport cyplist


cdef Str concatenator(Str a, Str b) nogil:
    """Try a function to make a + b Str
    """
    return Str(sprintf("%s%s", a, b))

cdef cypclass DemoString:
    """A demo cypclass, to experiment how to stay as long as possible in the nogil
    perimeter
    """
    Str s1
    Str s2
    Str concat
    Str concat2
    Str s3
    Str s4
    Str b1  # no bytes type in cypclass: Str IS the bytes class
    # cyplist[char] char_list

    # loading some Str param from "GIL perimeter" ?"
    __init__(self, Str parameter):  # remember: no default parameter allowed
        self.s1 = parameter
        self.s2 = Str("abcdef")
        self.concat = sprintf("%s%s", self.s1, self.s2)
        self.concat2 = concatenator(self.s1, self.s2)
        self.s3 = Str("")
        self.b1 = Str(Str.to_c_str(Str("convert to char*")))  # content can be a C like char*

    void gil_load_bytes(self, bytes parameter) with gil:
        self.s3 = Str(parameter)

    void gil_load_str(self, bytes parameter) with gil:
        # str instance must be converted to bytes outside cypclass, no actual load_str
        self.s4 = Str(parameter)


    # Will experiment more on this:
    # cyplist[char] Str_content_to_list(self):
    #     cdef cyplist[char] m
    #     for c in self.concat:  # list comprehension ?
    #         m.append(c)
    #     return m

    void print_demo(self):
        cdef int a = 0
        cdef Str sub_string
        cdef int test = 0

        printf("s1:  %s\n", self.s1)  # printf accept "" format parameter
        printf("s2:  %s\n", self.s2)
        printf("concat:  %s\n", self.concat)
        printf("concat2: %s\n", self.concat2)
        # Str == is based on content:
        printf("concat == concat2: %d\n", self.concat == self.concat2)
        printf("s3:  %s\n", self.s3)
        printf("s4:  %s\n", self.s4)
        printf("b1:  %s\n", self.b1)
        printf("length of concat Str: %d\n", self.concat.__len__())
        # printf("%s\n", a)  # segfault python (int in %s)
        a = self.concat.find(Str("C"))
        printf("position of C: %d\n", a)
        sub_string = self.concat.substr(a)
        printf("substring from C: %s\n", sub_string)
        printf("substring == original: %d\n", sub_string == self.concat)
        #printf("substring > original: %d\n", sub_string > self.concat)  # no more....
        #printf("substring < original: %d\n", sub_string < self.concat)  # no more....
        printf("loop: ")

        # here looping on some "local" c varibale is working:
        test = 0
        # for c in self.concat:  #string_exp.pyx:81:17: missing begin() on Str
        #     test = test + 1
        #     printf("%c ", c)
        printf("  (%d)\n", test)
        printf("\n")

    Str get_s1(self):
        return self.s1

    char* get_s2(self):
        return Str.to_c_str(self.s2)


def main():
    python_str = "some python str"
    cdef str cython_str  # and some cdef str container

    cdef DemoString demo_string

    with nogil:  # starting in nogil to see if it is possible to pass arguments

        # nogil perimeter can not start while working on PyObject, so:
        with gil:  # required
            cython_str = python_str
            demo_string = DemoString(Str(cython_str.encode("utf8")))

        # not possible because still using the cython_str PyObject
        # demo_string = DemoString(string(cython_str))
        # but this is possible:
        demo_string = DemoString(Str("ABCDEF"))

        # loading into instance will require a "with gil" in the method:
        demo_string.gil_load_bytes(b"some bytes")

        # loading a PyObject into instance will require a "with gil" in the method
        # AND in the caller:
        with gil:
            demo_string.gil_load_str(cython_str.encode("utf8"))  # convert to bytes

        # and now some "print" demo:
        demo_string.print_demo()
        # get some return value
        printf("returning some string\n")
        # this is working ok with nogil:
        printf("s1: %s\n", demo_string.get_s1())
        printf("s2 c_str: %s\n", demo_string.get_s2())
        printf("s2 attr: %s\n", demo_string.s2)
        with gil:
            print("And with gil to str:")
            cython_str = Str.to_c_str(demo_string.s1).decode("utf8")
            print(cython_str)
    print()
    print("The end.")
