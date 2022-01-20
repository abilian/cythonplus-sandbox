# distutils: language = c++

# Frequently cimported:
from libc.stdio cimport *

from libcythonplus.list cimport cyplist
from libcythonplus.dict cimport cypdict
from libcythonplus.set cimport cypset

from stdlib.string cimport Str
from stdlib._string cimport string
from stdlib.format cimport format



cdef int gpos(int)
cdef int gpos2(int) nogil
