# distutils: language = c++
from posix.types cimport off_t, time_t
from libcythonplus.list cimport cyplist
from libcythonplus.dict cimport cypdict
from stdlib.string cimport Str


cdef Str getdefault(Sdict d, Str key, Str default) nogil:
    if key in d:
        return d[key]
    return default
