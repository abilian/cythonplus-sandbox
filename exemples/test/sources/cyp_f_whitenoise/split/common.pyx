# distutils: language = c++
from posix.types cimport off_t, time_t
from libcythonplus.list cimport cyplist
from libcythonplus.dict cimport cypdict
from stdlib.string cimport Str
from stdlib._string cimport string


cdef Str getdefault(Sdict d, Str key, Str default) nogil:
    if key in d:
        return d[key]
    return default

#
# cdef Str to_str(str s):
#     return Str(s.encode("utf8"))
#
#
# cdef from_str(Str s):
#     return s.bytes().decode("utf8", 'replace')
#
#
# cdef string py_to_string(str s):
#     return Str(s.encode("utf8"))._str
#
#
# cdef string_to_py(string s):
#     return s.c_str().decode("utf8", 'replace')
