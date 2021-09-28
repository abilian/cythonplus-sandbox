# distutils: language = c++
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf

cdef string fa() nogil:
    return string("aaa")
