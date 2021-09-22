# distutils: language = c++
"""
Cython+ experiment with cypdict / string/long
(using syntax of september 2021)
"""
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf

from libcythonplus.dict cimport cypdict

# we make experiment with always the same type:
ctypedef cypdict[long, long] NumDict
ctypedef cypdict[string, long] LongDict
ctypedef cypdict[string, string] StringDict
ctypedef cypdict[string, float] FloatDict
ctypedef fused AnyDict:
    NumDict
    LongDict
    StringDict
    FloatDict

cdef SuperDict new_super_dict(AnyDict ad) nogil:
    """Construtor of SuperDict instance, using fused

    (nogil)
    """
    cdef SuperDict sd
    sd = SuperDict()
    if AnyDict is NumDict:
        sd.load_num_dict(ad)
    if AnyDict is LongDict:
        sd.load_long_dict(ad)
    if AnyDict is StringDict:
        sd.load_string_dict(ad)
    if AnyDict is FloatDict:
        sd.load_float_dict(ad)
    return sd

# no fused
# cdef cypclass SuperDict:
#     string active
#
#     __init__(self):
#         self.active = string("")
#
#     void detect(self, AnyDict d):
#         if AnyDict is NumDict:
#             printf("NumDict")

cdef cypclass SuperDict:
    string active
    NumDict num_dict
    LongDict long_dict
    StringDict string_dict
    FloatDict float_dict

    __init__(self):
        self.active = string("")

    void load_num_dict(self, NumDict num_dict):
        self.active = string("num_dict")
        self.num_dict = num_dict

    void load_long_dict(self, LongDict long_dict):
        self.active = string("long_dict")
        self.long_dict = long_dict

    void load_string_dict(self, StringDict string_dict):
        self.active = string("string_dict")
        self.string_dict = string_dict

    void load_float_dict(self, FloatDict float_dict):
        self.active = string("float_dict")
        self.float_dict = float_dict


cdef NumDict to_num_dict(python_dict):
    """create a NumDict instance from a int/int python dict

    (need gil)
    """
    dic = NumDict()
    for k, v in python_dict.items():
        dic[<long> k] = <long> v
    return dic


cdef string num_dict_repr(NumDict dic) nogil:
    """Some kind of __repr__ for NumDict type

    (nogil)
    """
    cdef string result = string("NumDict({")
    cdef bint first_one = True

    # we may need a cypclass for tuple and/or item_type ?
    # item is not useable in nogil context
    # for item in dic.items(): # not usable without GIL
    for item in dic.items():
        s = sprintf("%d:%d", <long> item.first, <long> item.second)
    # for k in dic.keys():
    #     s = sprintf("%d:%d", <long> k, <long> dic[k])
        if result.size() + s.size() > 70:
            result = sprintf("%s,...", result)
            break
        if first_one:
            result = sprintf("%s%s", result, s)
            first_one = False
        else:
            result = sprintf("%s, %s", result, s)
    result = sprintf("%s})", result)
    return result



def main():
    cdef NumDict dic
    cdef SuperDict sdic

    orig_num_dict = {0:0, 1:1, 2:1, 3:2, 4:3, 5:5, 6:8}

    print('Start')

    dic = to_num_dict(orig_num_dict)

    sdic = new_super_dict(dic)

    printf("super dict active: %s \n", sdic.active)
    print()
    print("The end.")
