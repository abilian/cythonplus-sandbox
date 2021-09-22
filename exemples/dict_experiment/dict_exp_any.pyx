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
ctypedef cypdict[string, double] FloatDict
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

    void load_num_dict(self, NumDict d):
        self.active = string("num_dict")
        self.num_dict = d

    void load_long_dict(self, LongDict d):
        self.active = string("long_dict")
        self.long_dict = d

    void load_string_dict(self, StringDict d):
        self.active = string("string_dict")
        self.string_dict = d

    void load_float_dict(self, FloatDict d):
        self.active = string("float_dict")
        self.float_dict = d

    string repr(self):
        if self.active == string("num_dict"):
            return num_dict_repr(self.num_dict)
        if self.active == string("string_dict"):
            return string_dict_repr(self.string_dict)
        with gil:
            raise ValueError("Not implemented...")


cdef SuperDict python_dict_to_super_dict(dict d):
    """Detect the type of values of a homogenous python dict, return
    the corresponding SuperDict instance

    (need gil)
    """
    cdef StringDict str_dict
    cdef NumDict num_dict

    if not d:
        # empty dict default to StringDict
        str_dict = StringDict()
        return new_super_dict(str_dict)

    for item in d.items():
        k, v = item
        break  # read only one item

    if isinstance(k, int):
        if isinstance(v, int):
            num_dict = to_num_dict(d)
            return new_super_dict(num_dict)
        else:
            raise ValueError("Unsupported dict type")
    elif isinstance(k, (str, bytes)):
        if isinstance(v, (str, bytes)):
            str_dict = to_string_dict(d)
            return new_super_dict(str_dict)
        else:
            raise ValueError("Unsupported dict type")
            # see later for more types
    else:
        raise ValueError("Unsupported dict type")

########### from NumDict module:
cdef NumDict to_num_dict(python_dict):
    """create a NumDict instance from a int/int python dict

    (need gil)
    """
    dic = NumDict()
    for k, v in python_dict.items():
        dic[<long> k] = <long> v
    return dic


cdef dict from_num_dict(NumDict nd):
    """create a python dict instance from a NumDict

    (need gil)
    """
    return {item.first:item.second for item in nd.items()}


cdef string num_dict_repr(NumDict dic) nogil:
    """Some kind of __repr__ for NumDict type

    (nogil)
    """
    cdef string result = string("NumDict({")
    cdef bint first_one = True

    # we may need a cypclass for tuple and/or item_type ?
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

########### / from NumDict module

########### from StringDict module
cdef StringDict to_string_dict(python_dict):
    """create a StringDict instance from a str/str python dict (str or bytes)

    (need gil)
    """
    dic = StringDict()
    for k, v in python_dict.items():
        # some error to not have: "Casting temporary Python object to non-numeric non-Python type"
        if isinstance(k, str):
            sk = string(bytes(k.encode("utf8")))
        else:
            sk = string(bytes(k))
        if isinstance(k, str):
            sv = string(bytes(v.encode("utf8")))
        else:
            sv = string(bytes(v))
        dic[sk] = sv
    return dic


cdef dict from_string_dict(StringDict dic):
    """create a python dict instance from a StringDict

    (need gil)
    """
    return {
        i.first.decode("utf8", 'replace'): i.second.decode("utf8", 'replace')
        for i in dic.items()
    }


cdef string string_dict_repr(StringDict dic) nogil:
    """Some kind of __repr__ for StringDict type

    (nogil)
    """
    cdef string result = string("StringDict({")
    cdef bint first_one = True

    for item in dic.items():
        s = sprintf("%s:%s", item.first, item.second)
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

########### /from StringDict module


def main():
    cdef NumDict test_dic1
    cdef SuperDict sdic1, sdic2

    orig_num_dict = {0: 0, 1: 1, 2: 1, 3: 2, 4: 3, 5: 5, 6: 8}
    orig_string_dict = {"a": "A", "b": "B", "c": "C", "d": "D"}

    print('Start')

    test_dic1 = to_num_dict(orig_num_dict)
    sdic1 = new_super_dict(test_dic1)
    printf("test1, super dict type: %s \n", sdic1.active)

    print()

    sdic2 = python_dict_to_super_dict(orig_num_dict)
    printf("test2a, super dict type: %s \n", sdic2.active)
    printf("test2a, super dict repr(): \n    %s\n", sdic2.repr())

    print()
    print("Same super dict instance will now store another type of dict:")
    sdic2 = python_dict_to_super_dict(orig_string_dict)
    printf("test2b, super dict type: %s \n", sdic2.active)
    printf("test2b, super dict repr(): \n    %s\n", sdic2.repr())

    print()
    print("The end.")
