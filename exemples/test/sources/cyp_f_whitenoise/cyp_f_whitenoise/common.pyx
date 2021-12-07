from libcythonplus.list cimport cyplist
from libcythonplus.dict cimport cypdict
from stdlib.string cimport Str


cdef Str getdefault(SDict d, Str key, Str default) nogil:
    if key in d:
        return d[key]
    return default
