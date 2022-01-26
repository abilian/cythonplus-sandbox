from stdlib.string cimport Str
from stdlib._string cimport npos
from libcythonplus.dict cimport cypdict
from stdlib.format cimport format


cdef int replace_one(Str, Str, Str) nogil
cdef int replace_all(Str, Str, Str) nogil
cdef void escape(Str, cypdict[Str, Str]) nogil
cdef void unescape(Str, cypdict[Str, Str]) nogil
cdef void quoteattr(Str, cypdict[Str, Str]) nogil
cdef Str nameprep(Str) nogil
