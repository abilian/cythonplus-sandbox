# distutils: language = c++
"""
Cython+ experiment for super class AnyScalarList
(using syntax of september 2021)
"""
from libcythonplus.list cimport cyplist
from stdlib.string cimport string
from stdlib.fmt cimport sprintf
from containerlib.any_scalar cimport *


cdef string anyscalar_list_repr(AnyScalarList) nogil
cdef AnyScalarList py_to_anyscalar_list(list)
cdef list anyscalar_list_to_py(AnyScalarList)
