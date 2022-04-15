# distutils: language = c++
"""
Cython+ experiment for super class AnyScalarDict
(using syntax of september 2021)
"""
from libcythonplus.dict cimport cypdict
from stdlib.string cimport string
from stdlib.fmt cimport sprintf
from containerlib.any_scalar cimport *


cdef string anyscalar_dict_repr(AnyScalarDict) nogil
cdef AnyScalarDict py_to_anyscalar_dict(dict)
cdef dict anyscalar_dict_to_py(AnyScalarDict)
