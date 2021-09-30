# distutils: language = c++
"""
Cython+ experiment for super class AnyScalarDict
(using syntax of september 2021)
"""
from libcythonplus.dict cimport cypdict
from stdlib.string cimport string
from stdlib.fmt cimport sprintf
from containerlib.any_scalar cimport *
from containerlib.any_scalar import *


cdef unsigned int _cont_repr_max_len = 70


cdef string anyscalar_dict_repr(AnyScalarDict dic) nogil:
    """Some kind of __repr__ for AnyScalarDict type

    (nogil)
    """
    cdef string result = string("AnyScalarDict({")
    cdef bint first_one = True

    for item in dic.items():
        s = sprintf("%s:%s", item.first, item.second.short_repr())
        if result.size() + s.size() > _cont_repr_max_len:
            result = sprintf("%s, ...", result)
            break
        if first_one:
            result = sprintf("%s%s", result, s)
            first_one = False
        else:
            result = sprintf("%s, %s", result, s)
    result = sprintf("%s})", result)
    return result


cdef AnyScalarDict py_to_anyscalar_dict(dict python_dict):
    """create a AnyScalarDict instance from a str/* python dict

    (need gil)
    """
    asd = AnyScalarDict()
    for key, value in python_dict.items():
        if isinstance(key, str):
            string_key = string(bytes(key.encode("utf8")))
        else:
            string_key = string(bytes(key))
        # create the AnyScalar wrapper:
        asd[string_key] = py_to_anyscalar(value)
    return asd


cdef dict anyscalar_dict_to_py(AnyScalarDict dic):
    """create a python dict instance from a AnyScalarDict

    (need gil)
    """
    return {
        i.first.decode("utf8", 'replace'): anyscalar_to_py(i.second)
        for i in dic.items()
    }
