# distutils: language = c++
from stdlib.string cimport Str


cdef int replace_one(Str, Str, Str) nogil
cdef int replace_all(Str, Str, Str) nogil
cdef void escape(Str) nogil
