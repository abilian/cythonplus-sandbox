# distutils: language = c++
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf


cdef cypclass Engine:
    long aaa

    __init__(self, data):
        self.aaa = 0



cpdef py_engine(data):
    return "toto"
