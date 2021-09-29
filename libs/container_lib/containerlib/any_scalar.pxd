# distutils: language = c++
"""
Cython+ experiment for abstract super class AnyScalar
(using syntax of september 2021)
"""
from stdlib.string cimport string
from stdlib.string cimport string
from libcythonplus.dict cimport cypdict
from libcythonplus.list cimport cyplist

ctypedef cypdict[string, AnyScalar] AnyScalarDict
ctypedef cyplist[AnyScalar] AnyScalarList
ctypedef unsigned char anytype_t
ctypedef fused AnyBaseType:
    string
    long
    double
    AnyScalarDict
    AnyScalarList
    AnyScalar


cdef cypclass AnyScalar:
    anytype_t type
    string a_string         # type "s" or type "b"
    long a_long             # type "i"
    double a_double         # type "f"
    AnyScalarDict a_dict    # type "d"
    AnyScalarList a_list    # type "l"
    # StringDict  Would be too much
    # NumDict
    # LongDict
    # FloatDict

    __init__(self):
        self.clean()

    void clean(self):
        if self.type == <anytype_t> " ":
            # already cleaned
            return
        self.a_string = string("")
        self.a_long = 0
        self.a_double = 0.0
        self.a_dict = NULL
        self.a_list = NULL
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

    void set_dict(self, AnyScalarDict value):
        """special case, value is already a AnyScalarDict, not a python dict
        """
        self.clean()
        self.type = <anytype_t> "d"
        self.a_dict = value

    void set_list(self, AnyScalarList value):
        """special case, value is already a AnyScalarList, not a python dict
        """
        self.clean()
        self.type = <anytype_t> "l"
        self.a_list = value

    void set_anyscalar(self, AnyScalar as):
        self.clean()
        self.type = as.type
        self.a_string = as.a_string
        self.a_long = as.a_long
        self.a_double = as.a_double
        self.a_dict = as.a_dict
        self.a_list = as.a_list

    string repr(self):
        if self.type == <anytype_t> "i":
            return scalar_i_repr(self.a_long)
        if self.type == <anytype_t> "f":
            return scalar_d_repr(self.a_double)
        if self.type == <anytype_t> "s":
            return scalar_s_repr(self.a_string)
        if self.type == <anytype_t> "b":
            return scalar_b_repr(self.a_string)
        if self.type == <anytype_t> "d":
            return string("AnyScalarDict(...)")
        if self.type == <anytype_t> "l":
            return string("AnyScalarList(...)")
        return string("AnyScalar(empty)")

    string short_repr(self):
        if self.type == <anytype_t> "i":
            return scalar_i_short_repr(self.a_long)
        if self.type == <anytype_t> "f":
            return scalar_d_short_repr(self.a_double)
        if self.type == <anytype_t> "s":
            return scalar_s_short_repr(self.a_string)
        if self.type == <anytype_t> "b":
            return scalar_b_short_repr(self.a_string)
        if self.type == <anytype_t> "d":
            return string("{...}")
        if self.type == <anytype_t> "l":
            return string("[...]")
        return string("(empty)")



cdef string scalar_i_repr(long) nogil
cdef string scalar_d_repr(double) nogil
cdef string scalar_s_repr(string) nogil
cdef string scalar_b_repr(string) nogil

cdef string scalar_i_short_repr(long) nogil
cdef string scalar_d_short_repr(double) nogil
cdef string scalar_s_short_repr(string) nogil
cdef string scalar_b_short_repr(string) nogil

cdef AnyScalar new_any_scalar(AnyBaseType) nogil
cdef any_scalar_to_python(AnyScalar)
cdef AnyScalar python_to_any_scalar(object)
