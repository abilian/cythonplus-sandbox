# distutils: language = c++
"""
Cython+ wrapper class for scalar dicts
(using syntax of september 2021)
"""
from libcythonplus.dict cimport cypdict
from stdlib.string cimport string
from stdlib.fmt cimport sprintf


cdef unsigned int _cont_repr_max_len = 70


############  StringDict  #####################################

cdef string string_dict_repr(StringDict sd) nogil:
    """Some kind of __repr__ for StringDict type.

    (nogil)
    """
    cdef string result = string("StringDict({")
    cdef bint first_one = True

    for item in sd.items():
        s = sprintf("%s:%s", item.first, item.second)
        if result.size() + s.size() > _cont_repr_max_len:
            result = sprintf("%s, ...", result)
            break
        if first_one:
            result = sprintf("%s%s", result, s)
            first_one = False
        else:
            result = sprintf("%s, %s", result, s)
    result = sprintf("%s})", result)
    return result


cdef StringDict to_string_dict(dict python_dict):
    """Create a StringDict instance from a str/str python dict (str or bytes accepted).

    (need gil)
    """
    sd = StringDict()
    for k, v in python_dict.items():
        # some error to not have: "Casting temporary Python object to non-numeric non-Python type"
        if isinstance(k, str):
            sk = string(bytes(k.encode("utf8")))
        else:
            sk = string(bytes(k))
        if isinstance(v, str):
            sv = string(bytes(v.encode("utf8")))
        else:
            sv = string(bytes(v))
        sd[sk] = sv
    return sd


cdef dict from_string_dict(StringDict sd):
    """Create a python dict instance from a StringDict.

    (need gil)
    """
    return {
        i.first.decode("utf8", 'replace'): i.second.decode("utf8", 'replace')
        for i in sd.items()
    }

############  / StringDict  #####################################

############  NumDict  #####################################

cdef string num_dict_repr(NumDict nd) nogil:
    """Some kind of __repr__ for NumDict type.

    (nogil)
    """
    cdef string result = string("NumDict({")
    cdef bint first_one = True

    for item in nd.items():
        s = sprintf("%d:%d", <long> item.first, <long> item.second)
        if result.size() + s.size() > _cont_repr_max_len:
            result = sprintf("%s, ...", result)
            break
        if first_one:
            result = sprintf("%s%s", result, s)
            first_one = False
        else:
            result = sprintf("%s, %s", result, s)
    result = sprintf("%s})", result)
    return result


cdef NumDict to_num_dict(dict python_dict):
    """Create a NumDict instance from a int/int python dict.

    (need gil)
    """
    dic = NumDict()
    for k, v in python_dict.items():
        dic[<long> k] = <long> v
    return dic


cdef dict from_num_dict(NumDict nd):
    """Create a python dict instance from a NumDict.

    (need gil)
    """
    return {item.first:item.second for item in nd.items()}

############  / NumDict  #####################################

############  LongDict  #####################################

cdef string long_dict_repr(LongDict ld) nogil:
    """Some kind of __repr__ for LongDict type.

    (nogil)
    """
    cdef string result = string("LongDict({")
    cdef bint first_one = True

    for item in ld.items():
        s = sprintf("%s:%d", item.first, <long> item.second)
        if result.size() + s.size() > _cont_repr_max_len:
            result = sprintf("%s, ...", result)
            break
        if first_one:
            result = sprintf("%s%s", result, s)
            first_one = False
        else:
            result = sprintf("%s, %s", result, s)
    result = sprintf("%s})", result)
    return result


cdef LongDict to_long_dict(dict python_dict):
    """Create a LongDict instance from a str/int python dict (accept bytes/int).

    (need gil)
    """
    ld = LongDict()
    for k, v in python_dict.items():
        # some error to not have: "Casting temporary Python object to non-numeric non-Python type"
        if isinstance(k, str):
            sk = string(bytes(k.encode("utf8")))
        else:
            sk = string(bytes(k))
        ld[sk] = <long> v
    return ld


cdef dict from_long_dict(LongDict ld):
    """Create a python dict instance from a LongDict.

    (need gil)
    """
    return {i.first.decode("utf8", 'replace'): i.second for i in ld.items()}

############  / LongDict  #####################################

############  FloatDict  #####################################

cdef string float_dict_repr(FloatDict fd) nogil:
    """Some kind of __repr__ for FloatDict type.

    (nogil)
    """
    cdef string result = string("FloatDict({")
    cdef bint first_one = True

    for item in fd.items():
        s = sprintf("%s:%.6f", item.first, <double> item.second)
        if result.size() + s.size() > _cont_repr_max_len:
            result = sprintf("%s, ...", result)
            break
        if first_one:
            result = sprintf("%s%s", result, s)
            first_one = False
        else:
            result = sprintf("%s, %s", result, s)
    result = sprintf("%s})", result)
    return result


cdef FloatDict to_float_dict(dict python_dict):
    """Create a FloatDict instance from a str/float python dict.

    (need gil)
    """
    fd = FloatDict()
    for k, v in python_dict.items():
        # some error to not have: "Casting temporary Python object to non-numeric non-Python type"
        if isinstance(k, str):
            sk = string(bytes(k.encode("utf8")))
        else:
            sk = string(bytes(k))
        fd[sk] = <double> v
    return fd


cdef dict from_float_dict(FloatDict fd):
    """Create a python dict instance from a FloatDict..

    (need gil)
    """
    return {i.first.decode("utf8", 'replace'): i.second for i in fd.items()}

############  / FloatDict  #####################################

############  SuperDict  #####################################

cdef SuperDict new_super_dict(AnyDict ad) nogil:
    """Constructor of SuperDict instance, using fused AnyDict as input.

    SuperDict is a wrapper around the classes of fused AnyDict.

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


cdef SuperDict python_dict_to_super_dict(dict d):
    """Detect the type of values of a homogenous python dict, return
    the corresponding SuperDict instance.

    (need gil)
    """
    cdef StringDict str_dict
    cdef NumDict num_dict
    cdef LongDict long_dict
    cdef FloatDict float_dict

    if not d:
        # empty dict default to StringDict
        str_dict = StringDict()
        return new_super_dict(str_dict)

    # detection of type of assumed homogenous python dict:
    for item in d.items():
        k, v = item
        break  # read only one item

    if isinstance(k, int):
        if isinstance(v, int):
            num_dict = to_num_dict(d)
            return new_super_dict(num_dict)
        else:
            raise ValueError("Unsupported dict variant")
    elif isinstance(k, (str, bytes)):
        if isinstance(v, (str, bytes)):
            str_dict = to_string_dict(d)
            return new_super_dict(str_dict)
        elif isinstance(v, int):
            long_dict = to_long_dict(d)
            return new_super_dict(long_dict)
        elif isinstance(v, float):
            float_dict = to_float_dict(d)
            return new_super_dict(float_dict)
        else:
            raise ValueError("Unsupported dict variant")
            # see later for more types
    else:
        raise ValueError("Unsupported dict variant")


cdef dict super_dict_to_python_dict(SuperDict sd):
    """Return a python dict from SuperDict instance.

    (need gil)
    """
    if sd.type == string("NumDict"):
        return from_num_dict(sd.num_dict)
    if sd.type == string("StringDict"):
        return from_string_dict(sd.string_dict)
    if sd.type == string("LongDict"):
        return from_long_dict(sd.long_dict)
    if sd.type == string("FloatDict"):
        return from_float_dict(sd.float_dict)
    if sd.type == string(""):
        return {}
    raise ValueError("Not implemented")

############  / SuperDict  #####################################
