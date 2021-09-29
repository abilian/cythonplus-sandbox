# distutils: language = c++
"""
Cython+ experiment for super class AnyScalarList
(using syntax of september 2021)
"""
from libcythonplus.list cimport cyplist
from stdlib.string cimport string
from stdlib.fmt cimport sprintf
from containerlib.any_scalar cimport *
from containerlib.any_scalar import *


cdef unsigned int _cont_repr_max_len = 70


cdef string anyscalar_list_repr(AnyScalarList lst) nogil:
    """Some kind of __repr__ for AnyScalarList type

    (nogil)
    """
    cdef string result = string("AnyScalarList([")
    cdef bint first_one = True

    for item in lst:
        s = sprintf("%s", item.short_repr())
        if result.size() + s.size() > _cont_repr_max_len:
            result = sprintf("%s, ...", result)
            break
        if first_one:
            result = sprintf("%s%s", result, s)
            first_one = False
        else:
            result = sprintf("%s, %s", result, s)
    result = sprintf("%s])", result)
    return result


cdef AnyScalarList to_anyscalar_list(list python_list):
    """create a AnyScalarList instance from a python list

    (need gil)
    """
    asl = AnyScalarList()
    for item in python_list:
        asl.append(python_to_any_scalar(item))
    return asl


cdef list from_anyscalar_list(AnyScalarList lst):
    """create a python dict instance from a AnyScalarList

    (need gil)
    """
    return [any_scalar_to_python(i) for i in lst]
