from libcythonplus.list cimport cyplist
from libcythonplus.dict cimport cypdict
from .stdlib.formatdate cimport formatlog
from stdlib.string cimport Str
from stdlib._string cimport string
from posix.types cimport off_t, time_t


ctypedef cyplist[Str] StrList
ctypedef cypdict[string, Finfo] Fdict


cdef cypclass Finfo:
    "minimal file informtion"
    off_t size
    time_t mtime

    __init__(self, off_t size, time_t mtime):
        self.size = size
        self.mtime = mtime


cdef Str getdefault(cypdict[Str, Str], Str, Str) nogil
cdef void xlog(msg)
