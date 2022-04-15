# containerlib

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
    cdef StringDict py_to_string_dict(dict)
    cdef dict string_dict_to_py(StringDict)

NumDict is for cypdict[long, long]:

    cdef string num_dict_repr(NumDict) nogil
    cdef NumDict py_to_num_dict(dict)
    cdef dict num_dict_to_py(NumDict)

LongDict is for cypdict[string, long]:

    cdef string long_dict_repr(LongDict) nogil
    cdef LongDict py_to_long_dict(dict)
    cdef dict long_dict_to_py(LongDict)

FloatDict is for cypdict[string, double]:

    cdef string float_dict_repr(FloatDict) nogil
    cdef FloatDict py_to_float_dict(dict)
    cdef dict float_dict_to_py(FloatDict)

SuperDict to rule them all:

    cdef cypclass SuperDict:
    cdef SuperDict new_superdict(AnyDict) nogil
    cdef SuperDict py_to_superdict(dict)
    cdef dict superdict_to_py(SuperDict)


## any_scalar

Wrappers above most common python "scalar" types. The AnyScalar class will permit to
build the dict-like class AnyScalarDict containing heterogeneous scalar values.

    cdef cypclass AnyScalar:
        anytype_t type
        string a_string         # type "s" or type "b"
        long a_long             # type "i"
        double a_double         # type "f"
        AnyScalarDict a_dict    # type "d"
        AnyScalarList a_list    # type "l"
        ...


    cdef string scalar_i_repr(long) nogil
    cdef string scalar_d_repr(double) nogil
    cdef string scalar_s_repr(string) nogil
    cdef string scalar_b_repr(string) nogil

    cdef string scalar_i_short_repr(long) nogil
    cdef string scalar_d_short_repr(double) nogil
    cdef string scalar_s_short_repr(string) nogil
    cdef string scalar_b_short_repr(string) nogil

    cdef anyscalar_to_py(AnyScalar)
    cdef AnyScalar py_to_anyscalar(object)


## any_scalar_dict

A dict-like cypclass containing heterogeneous scalar values.

    ctypedef cypdict[string, AnyScalar] AnyScalarDict  # defined in any_scalar.pxd

    cdef string anyscalar_dict_repr(AnyScalarDict) nogil
    cdef AnyScalarDict py_to_anyscalar_dict(dict)
    cdef dict anyscalar_dict_to_py(AnyScalarDict)


## any_scalar_list

A list-like cypclass containing heterogeneous scalar values.

    ctypedef cyplist[AnyScalar] AnyScalarList  # defined in any_scalar.pxd

    cdef string anyscalar_list_repr(AnyScalarList) nogil
    cdef AnyScalarList py_to_anyscalar_list(list)
    cdef list anyscalar_list_to_py(AnyScalarList)
