from libcythonplus.list cimport cyplist
from stdlib.string cimport Str, isspace
from stdlib._string cimport npos


cdef int replace_one(Str, Str, Str) nogil
cdef Str stripped(Str) nogil
cdef cyplist[Str] cypstr_split_tuple(Str) nogil
