# distutils: language = c++
"""
Show compiler max limits
"""
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf

from libcpp.limits cimport numeric_limits


cdef cypclass TypeInfo:
    string name
    int lm_digits
    unsigned long long lm_max
    long double lm_float_max

    void print_info_base(self):
        printf("%s:\n", self.name)
        printf("    max value: %llu\n", self.lm_max)
        printf("       digits: %d\n\n", self.lm_digits)

    void print_info(self):
        self.print_info_base()


cdef cypclass BintInfo(TypeInfo):
    __init__(self):
        cdef numeric_limits[bint] lm

        self.name = string("bint (~ cython boolean)")
        self.lm_digits = lm.digits
        self.lm_max = lm.max()


cdef cypclass CharInfo(TypeInfo):
    __init__(self):
        cdef numeric_limits[char] lm

        self.name = string("char")
        self.lm_digits = lm.digits
        self.lm_max = lm.max()


cdef cypclass UcharInfo(TypeInfo):
    __init__(self):
        cdef numeric_limits[uchar] lm

        self.name = string("unsigned char")
        self.lm_digits = lm.digits
        self.lm_max = lm.max()


cdef cypclass ShortInfo(TypeInfo):
    __init__(self):
        cdef numeric_limits[short] lm

        self.name = string("short")
        self.lm_digits = lm.digits
        self.lm_max = lm.max()


cdef cypclass IntInfo(TypeInfo):
    __init__(self):
        cdef numeric_limits[int] lm

        self.name = string("int")
        self.lm_digits = lm.digits
        self.lm_max = lm.max()


cdef cypclass LongInfo(TypeInfo):
    __init__(self):
        cdef numeric_limits[long] lm

        self.name = string("long")
        self.lm_digits = lm.digits
        self.lm_max = lm.max()


cdef cypclass UlongInfo(TypeInfo):
    __init__(self):
        cdef numeric_limits[ulong] lm

        self.name = string("unsigned long")
        self.lm_digits = lm.digits
        self.lm_max = lm.max()


cdef cypclass LonglongInfo(TypeInfo):
    __init__(self):
        cdef numeric_limits[longlong] lm

        self.name = string("long long")
        self.lm_digits = lm.digits
        self.lm_max = lm.max()


cdef cypclass UlonglongInfo(TypeInfo):
    __init__(self):
        cdef numeric_limits[ulonglong] lm

        self.name = string("unsigned long long")
        self.lm_digits = lm.digits
        self.lm_max = lm.max()


cdef cypclass FloatInfo(TypeInfo):
    __init__(self):
        cdef numeric_limits[float] lm

        self.name = string("float")
        self.lm_digits = lm.digits
        self.lm_float_max = lm.max()

    void print_info_base(self):
        printf("%s:\n", self.name)
        printf("  max value: %Le\n", self.lm_float_max)
        printf("     digits: %d\n\n", self.lm_digits)


cdef cypclass DoubleInfo(FloatInfo):
    __init__(self):
        cdef numeric_limits[double] lm

        self.name = string("double")
        self.lm_digits = lm.digits
        self.lm_float_max = lm.max()


cdef cypclass LongdoubleInfo(FloatInfo):
    __init__(self):
        cdef numeric_limits[longdouble] lm

        self.name = string("long double")
        self.lm_digits = lm.digits
        self.lm_float_max = lm.max()


cdef show_limits():
    cdef BintInfo b = BintInfo()
    cdef CharInfo c = CharInfo()
    cdef UcharInfo uc = UcharInfo()
    cdef ShortInfo s = ShortInfo()
    cdef IntInfo i = IntInfo()
    cdef LongInfo l = LongInfo()
    cdef UlongInfo ul = UlongInfo()
    cdef LonglongInfo ll = LonglongInfo()
    cdef UlonglongInfo ull = UlonglongInfo()
    cdef FloatInfo f = FloatInfo()
    cdef DoubleInfo d = DoubleInfo()
    cdef LongdoubleInfo ld = LongdoubleInfo()

    b.print_info()
    c.print_info()
    uc.print_info()
    s.print_info()
    i.print_info()
    l.print_info()
    ul.print_info()
    ll.print_info()
    ull.print_info()
    f.print_info()
    d.print_info()
    ld.print_info()


def main():
    show_limits()
