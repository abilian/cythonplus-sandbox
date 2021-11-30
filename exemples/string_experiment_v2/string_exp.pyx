# distutils: language = c++
"""
Cython+ experiment with strings (and list): loading, printing,...
(using syntax of november 2021)
"""
from stdlib.string cimport Str
from stdlib.format cimport format
from libc.stdio cimport printf, puts

from libcythonplus.list cimport cyplist


cdef cypclass DemoString:
    """A demo cypclass, to experiment how to stay as long as possible in the nogil
    perimeter
    No more using fmt.sprintf but format.format
    """
    Str s1
    Str s2
    Str concat
    Str concat2
    Str s3
    Str s4
    Str b1  # no bytes type in cypclass: Str or string IS the bytes class
    # cyplist[char] char_list

    # loading some Str param from "GIL perimeter" ?"
    __init__(self, Str parameter):  # remember: no default parameter allowed
        self.s1 = parameter
        self.s2 = Str("abcdef")
        self.concat = format("{}{}", self.s1, self.s2)
        self.concat2 = self.s1 + self.s2
        self.s3 = Str("")
        self.b1 = Str(Str("a long string")._str.c_str())  # content can be a C like char*

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
        cdef Str sub_string, txt, c
        cdef int test = 0
        cdef cyplist[Str] splited


        printf("s1 v1:  %s\n", Str.to_c_str(self.s1))
        puts(format("s1 v2:  %s", self.s1)._str.c_str())
        puts(format("s1 v2a:  %s %d", self.s1._str.c_str(), 42)._str.c_str())
        puts(format("s1 v2b:  {}", self.s1)._str.c_str())
        puts(format("s1 v2b2:  {}  %d", self.s1, 42)._str.c_str())
        puts(format("s1 v2b2:  {}  {:d} {:x}", self.s1, 42, 42)._str.c_str())
        txt = format("s1 v2c:  %s", self.s1)
        puts(Str.to_c_str(txt))
        puts(Str.to_c_str(format("s1 v3:  %s", self.s1)))

        puts(Str.to_c_str(format("s2:  %s", self.s2)))
        puts(Str.to_c_str(format("concat:  {}", self.concat)))
        puts(Str.to_c_str(format("concat2: {}", self.concat2)))
        # Str == is based on content:
        puts(Str.to_c_str(format("concat == concat2: %d", self.concat == self.concat2)))
        puts(Str.to_c_str(format("s3:  %s", self.s3)))
        puts(Str.to_c_str(format("s4:  %s", self.s4)))
        puts(Str.to_c_str(format("b1:  %s", self.b1)))
        puts(Str.to_c_str(format("length of concat Str: %d", self.concat.__len__())))
        # puts(Str.to_c_str(format("%s\n", a)  # segfault python (int in %s)
        a = self.concat.find(Str("C"))
        puts(Str.to_c_str(format("position of C: %d", a)))
        sub_string = self.concat.substr(a)
        puts(Str.to_c_str(format("substring from C: %s", sub_string._str)))
        puts(Str.to_c_str(format("substring == original: %d", sub_string == self.concat)))
        #puts(Str.to_c_str(format("substring > original: %d\n", sub_string > self.concat)  # no more....
        #puts(Str.to_c_str(format("substring < original: %d\n", sub_string < self.concat)  # no more....

        puts(Str.to_c_str(format("loop: ")))
        # here looping on some "local" c varibale is working:
        test = 0
        splited = self.concat.split()
        for c in splited:  #string_exp.pyx:81:17: missing begin() on Str
            printf("%s ", Str.to_c_str(c))
            printf("- %s ", c._str.c_str())
            printf("  (%d)", test)
            puts("")
            test = test + 1
        puts("------")
        puts(Str.to_c_str(Str("loop2: ")))
        test = 0
        for x in self.concat._str:  #string_exp.pyx:81:17: missing begin() on Str
            printf("%d: %c, ", test, x)
            test = test + 1
        puts("\n============")

    Str get_s1(self):
        return self.s1

    const char* get_s2(self):
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
        puts(Str.to_c_str(format("returning some string\n")))
        # this is working ok with nogil:
        puts(Str.to_c_str(format("s1: %s", demo_string.get_s1())))
        puts(Str.to_c_str(format("s2 c_str: %s", demo_string.get_s2())))
        puts(Str.to_c_str(format("s2 attr: %s", demo_string.s2)))
        with gil:
            print("And with gil to str:")
            cython_str = demo_string.s1._str.c_str().decode("utf8")
            print(cython_str)
    print()
    print("The end.")
