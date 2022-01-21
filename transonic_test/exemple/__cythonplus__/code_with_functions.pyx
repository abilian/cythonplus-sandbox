# distutils: language = c++

# Frequently cimported:
from libc.stdio cimport *

from libcythonplus.list cimport cyplist
from libcythonplus.dict cimport cypdict
from libcythonplus.set cimport cypset

from stdlib.string cimport Str
from stdlib._string cimport string
from stdlib.format cimport format

cdef int gpos(int n):
    """Return the value of position n of the Golomb sequence (recursive function).
    """
    cdef int val
    cdef Str something
    val = 0
    something = Str("")

    val = 1
    if n == val:
        return 1
    return gpos(n - gpos(gpos(n - 1))) + 1


cdef int gpos2(int n) nogil:
    """Return the value of position n of the Golomb sequence (recursive function).
    """
    cdef int val
    cdef cypdict[Str, int] somedict
    val = 0
    somedict = cypdict[Str, int]()

    val = 1
    if n == val:
        return 1
    return gpos2(n - gpos2(gpos2(n - 1))) + 1

__transonic__ = ('123.4.12',)