from posix.types cimport off_t, time_t
from libcythonplus.list cimport cyplist
from libcythonplus.dict cimport cypdict
from stdlib.string cimport Str


ctypedef cypdict[Str, Str] Sdict
ctypedef cyplist[Str] StrList
ctypedef cypdict[Str, Finfo] Fdict


cdef cypclass Finfo:
    "minimal file informtion"
    off_t size
    time_t mtime

    __init__(self, off_t size, time_t mtime):
        self.size = size
        self.mtime = mtime


cdef Str getdefault(Sdict, Str, Str) nogil
