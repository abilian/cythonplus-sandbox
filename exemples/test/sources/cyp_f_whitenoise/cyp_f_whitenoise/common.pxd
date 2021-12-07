from libcythonplus.list cimport cyplist
from libcythonplus.dict cimport cypdict
from stdlib.string cimport Str

ctypedef cypdict[Str, Str] Sdict
ctypedef cyplist[Str] StrList


cdef cypclass StrPair:
    Str first
    Str second

    __init__(self, Str a, Str b):
        self.first = a
        self.second = b

ctypedef cyplist[StrPair] HeaderList

cdef Str getdefault(SDict, Str, Str) nogil
