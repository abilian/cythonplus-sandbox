# distutils: language = c++
"""
Cython+ wrapper class for scalar dicts
(using syntax of september 2021)
"""
from libcythonplus.dict cimport cypdict
from stdlib.string cimport string
from stdlib.fmt cimport sprintf


ctypedef cypdict[string, string] StringDict
ctypedef cypdict[long, long] NumDict
ctypedef cypdict[string, long] LongDict
ctypedef cypdict[string, double] FloatDict
ctypedef fused AnyDict:
    StringDict
    NumDict
    LongDict
    FloatDict

############  StringDict  #####################################
cdef string string_dict_repr(StringDict) nogil
cdef StringDict to_string_dict(dict)
cdef dict from_string_dict(StringDict)
############  NumDict  #####################################
cdef string num_dict_repr(NumDict) nogil
cdef NumDict to_num_dict(dict)
cdef dict from_num_dict(NumDict)
############  LongDict  #####################################
cdef string long_dict_repr(LongDict) nogil
cdef LongDict to_long_dict(dict)
cdef dict from_long_dict(LongDict)
############  FloatDict  #####################################
cdef string float_dict_repr(FloatDict) nogil
cdef FloatDict to_float_dict(dict)
cdef dict from_float_dict(FloatDict)
############  SuperDict  #####################################
cdef cypclass SuperDict:
    """SuperDict is a wrapper around the classes of fused AnyDict
    (NumDict, LongDict, StringDict, FloatDict). These classes are homogeneous
    dictionaries.
    """
    string type
    NumDict num_dict
    LongDict long_dict
    StringDict string_dict
    FloatDict float_dict

    __init__(self):
        self._clean()

    void _clean(self):
        self.type = string("")
        self.num_dict = NULL
        self.long_dict = NULL
        self.string_dict = NULL
        self.float_dict = NULL

    void clean(self):
        if self.type == string(""):
            # already cleaned
            return
        self._clean()

    void load_num_dict(self, NumDict d):
        self.clean()
        self.type = string("NumDict")
        self.num_dict = d

    void load_long_dict(self, LongDict d):
        self.clean()
        self.type = string("LongDict")
        self.long_dict = d

    void load_string_dict(self, StringDict d):
        self.clean()
        self.type = string("StringDict")
        self.string_dict = d

    void load_float_dict(self, FloatDict d):
        self.clean()
        self.type = string("FloatDict")
        self.float_dict = d

    string repr(self):
        if self.type == string("NumDict"):
            return num_dict_repr(self.num_dict)
        if self.type == string("StringDict"):
            return string_dict_repr(self.string_dict)
        if self.type == string("LongDict"):
            return long_dict_repr(self.long_dict)
        if self.type == string("FloatDict"):
            return float_dict_repr(self.float_dict)
        if self.type == string(""):
            return string("SuperDict(empty)")
        with gil:
            raise ValueError("Not implemented")

cdef SuperDict new_super_dict(AnyDict) nogil
cdef SuperDict python_dict_to_super_dict(dict)
cdef dict super_dict_to_python_dict(SuperDict)
