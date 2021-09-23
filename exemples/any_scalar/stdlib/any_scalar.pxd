# distutils: language = c++
"""
Cython+ experiment for abstract super class AnyScalar
(using syntax of september 2021)
"""
from stdlib.string cimport string

ctypedef unsigned char anytype_t


cdef cypclass AnyScalar:
    anytype_t type
    string a_string     # type "s" or type "b"
    long a_long         # type "i"
    double a_double     # type "f"

    __init__(self):
        self.clean()

    void clean(self):
        if self.type == <anytype_t> " ":
            # already cleaned
            return
        self.a_string = string("")
        self.a_long = 0
        self.a_double = 0.0
        self.type = <anytype_t> " "

    void set_int(self, long value):
        self.clean()
        self.type = <anytype_t> "i"
        self.a_long = value

    void set_float(self, double value):
        self.clean()
        self.type = <anytype_t> "f"
        self.a_double = value

    void set_string(self, string value):
        self.clean()
        self.type = <anytype_t> "s"
        self.a_string = value

    void set_bytes(self, string value):
        # bytes and string only differ as python type. They both are stored in the
        # self.a_string slot.
        self.clean()
        self.type = <anytype_t> "b"
        self.a_string = value

    string repr(self):
        if self.type == <anytype_t> "i":
            return scalar_i_repr(self.a_long)
        if self.type == <anytype_t> "f":
            return scalar_d_repr(self.a_double)
        if self.type == <anytype_t> "s":
            return scalar_s_repr(self.a_string)
        if self.type == <anytype_t> "b":
            return scalar_b_repr(self.a_string)
        return string("AnySclaler(NULL)")


cdef string scalar_i_repr(long) nogil

cdef string scalar_d_repr(double) nogil

cdef string scalar_s_repr(string) nogil

cdef string scalar_b_repr(string) nogil

cdef any_scalar_to_python(AnyScalar)

cdef AnyScalar python_to_any_scalar(object)
