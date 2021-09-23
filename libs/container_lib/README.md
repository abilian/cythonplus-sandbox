# containerslib

A set of container utilities for cython+ cypclasses.


## scalar_dicts

Wrappers around cypdict[K, V]. The library defines a super class above most used
homogeneous dictionaries and functions to convert thoses dicts between python/gil
perimeter and cypclass/nogil perimeter:

    ctypedef fused AnyDict:
        StringDict
        NumDict
        LongDict
        FloatDict

StringDict is for cypdict[string, string]:

    cdef string string_dict_repr(StringDict) nogil
    cdef StringDict to_string_dict(dict)
    cdef dict from_string_dict(StringDict)

NumDict is for cypdict[long, long]:

    cdef string num_dict_repr(NumDict) nogil
    cdef NumDict to_num_dict(dict)
    cdef dict from_num_dict(NumDict)

LongDict is for cypdict[string, long]:

    cdef string long_dict_repr(LongDict) nogil
    cdef LongDict to_long_dict(dict)
    cdef dict from_long_dict(LongDict)

FloatDict is for cypdict[string, double]:

    cdef string float_dict_repr(FloatDict) nogil
    cdef FloatDict to_float_dict(dict)
    cdef dict from_float_dict(FloatDict)

SuperDict to rule them all:

    cdef cypclass SuperDict:
    cdef SuperDict new_super_dict(AnyDict) nogil
    cdef SuperDict python_dict_to_super_dict(dict)
    cdef dict super_dict_to_python_dict(SuperDict)


## any_scalar

Wrappers above most common python "scalar" types. The AnyScalar class will permit to
build the dict-like class AnyScalarDict containing heterogeneous scalar values.

    cdef cypclass AnyScalar:
        anytype_t type
        string a_string     # type "s" or type "b"
        long a_long         # type "i"
        double a_double     # type "f"
        ...


    cdef string scalar_i_repr(long) nogil
    cdef string scalar_d_repr(double) nogil
    cdef string scalar_s_repr(string) nogil
    cdef string scalar_b_repr(string) nogil

    cdef string scalar_i_short_repr(long) nogil
    cdef string scalar_d_short_repr(double) nogil
    cdef string scalar_s_short_repr(string) nogil
    cdef string scalar_b_short_repr(string) nogil

    cdef any_scalar_to_python(AnyScalar)
    cdef AnyScalar python_to_any_scalar(object)


## any_scalar_dict

A dict-like cypclass containing heterogeneous scalar values.

    ctypedef cypdict[string, AnyScalar] AnyScalarDict

    cdef string anyscalar_dict_repr(AnyScalarDict) nogil
    cdef AnyScalarDict to_anyscalar_dict(dict)
    cdef dict from_anyscalar_dict(AnyScalarDict)
