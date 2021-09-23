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


cdef AnyScalar python_to_any_scalar(value):
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
    else:
        any.clean()
    return any


cdef any_scalar_to_python(AnyScalar any):
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
    else:
        return None
