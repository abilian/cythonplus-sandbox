from libcythonplus.list cimport cyplist
from libcythonplus.dict cimport cypdict
from stdlib.string cimport Str


ctypedef cypdict[Str, Str] Sdict
ctypedef cyplist[Str] StrList

cdef Str getdefault(SDict, Str, Str) nogil
