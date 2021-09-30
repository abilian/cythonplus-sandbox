# distutils: language = c++
"""
Cython+ experiment for abstract super class AnyScalar
(using syntax of september 2021)
"""
from stdlib.string cimport string
from stdlib.fmt cimport sprintf


cdef string scalar_i_repr(long i) nogil:
    """Some kind of __repr__ for i type of AnyScalar

    (nogil)
    """
    return sprintf("AnyScalar(i, %d)", <long> i)


cdef string scalar_d_repr(double f) nogil:
    """Some kind of __repr__ for f type of AnyScalar

    (nogil)
    """
    return sprintf("AnyScalar(f, %.6f)", <double> f)


cdef string scalar_s_repr(string s) nogil:
    """Some kind of __repr__ for s type of AnyScalar

    (nogil)
    """
    return sprintf("AnyScalar(s, %s)", s)


cdef string scalar_b_repr(string s) nogil:
    """Some kind of __repr__ for b type of AnyScalar

    (nogil)
    """
    return sprintf("AnyScalar(b, %s)", s)


cdef string scalar_i_short_repr(long i) nogil:
    """Some kind of short __repr__ for i type of AnyScalar

    (nogil)
    """
    return sprintf("(i, %d)", <long> i)


cdef string scalar_d_short_repr(double f) nogil:
    """Some kind of short __repr__ for f type of AnyScalar

    (nogil)
    """
    return sprintf("(f, %.6f)", <double> f)


cdef string scalar_s_short_repr(string s) nogil:
    """Some kind of short __repr__ for s type of AnyScalar

    (nogil)
    """
    return sprintf("(s, %s)", s)


cdef string scalar_b_short_repr(string s) nogil:
    """Some kind of short __repr__ for b type of AnyScalar

    (nogil)
    """
    return sprintf("(b, %s)", s)


cdef AnyScalar new_anyscalar(AnyBaseType a) nogil:
    """Constructor of AnyScalar instance, using fused AnyBaseType as input.

    nota:
      - external constructor, cypclass don't accept fused types.
      - this is not a copy() function.

    (nogil)
    """
    cdef AnyScalar as

    as = AnyScalar()
    if AnyBaseType is string:
        as.set_string(a)
    elif AnyBaseType is long:
        as.set_int(a)
    elif AnyBaseType is double:
        as.set_float(a)
    elif AnyBaseType is AnyScalarDict:
        as.set_dict(a)
    elif AnyBaseType is AnyScalarList:
        as.set_list(a)
    elif AnyBaseType is AnyScalar:
        as.set_anyscalar(a)
    return as


cdef AnyScalar py_to_anyscalar(value):
    """Detect the type of values of a python type, return the corresponding AnyScalar
    instance

    (need gil)
    """
    cdef AnyScalar any

    any = AnyScalar()

    if isinstance(value, int):
        any.set_int(value)
    elif isinstance(value, str):
        any.set_string(string(bytes(value.encode("utf8"))))
    elif isinstance(value, bytes):
        any.set_bytes(string(bytes(value)))
    elif isinstance(value, float):
        any.set_float(value)
    elif isinstance(value, dict):
        asd = AnyScalarDict()
        for key, val in value.items():
            if isinstance(key, str):
                string_key = string(bytes(key.encode("utf8")))
            else:
                string_key = string(bytes(key))
            # create the AnyScalar wrapper:
            asd[string_key] = py_to_anyscalar(val)
        any.set_dict(asd)
    elif isinstance(value, list):
        asl = AnyScalarList()
        for item in value:
            asl.append(py_to_anyscalar(item))
        any.set_list(asl)
    else:
        any.clean()
    return any


cdef anyscalar_to_py(AnyScalar any):
    """Return the python value embeded in a AnyScalar

    (need gil)
    """
    if any.type == <anytype_t> 'i':
        return any.a_long
    elif any.type == <anytype_t> 'f':
        return any.a_double
    elif any.type == <anytype_t> 's':
        return any.a_string.decode("utf8", "replace")
    elif any.type == <anytype_t> 'b':
        return any.a_string
    elif any.type == <anytype_t> 'd':
        return {
            i.first.decode("utf8", 'replace'): anyscalar_to_py(i.second)
            for i in any.a_dict.items()
        }
    elif any.type == <anytype_t> 'l':
        return [anyscalar_to_py(i) for i in any.a_list]
    else:
        return None
