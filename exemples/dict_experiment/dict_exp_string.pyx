# distutils: language = c++
"""
Cython+ experiment with cypdict / string/string
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



cdef cypclass DemoStringDict:
    """A demo cypclass, to experiment how to stay as long as possible in the nogil
    perimeter

    - demo of a cypdict using scalars: StringDict
    """
    StringDict dic

    __init__(self, StringDict param_dic):  # remember: no default parameter allowed
        self.dic = param_dic

    void print_demo(self):
        """method executed with nogil status
        """
        printf("dic.__len__:  %d\n", self.dic.__len__())
        printf("dict content: %s\n", string_dict_repr(self.dic))  # using hand made repr()

        #### make some operations
        self.dic['alpha'] = string("new alpha")  # and hope we catch the b'alpha'
        # warn: here we need a cast:
        self.dic['beta'] = sprintf("%s%s", <string> self.dic['beta'], string(" more beta"))
        self.dic['gamma'] = string("three")  # here cast not needed
        del self.dic['delta']
        self.dic['other'] = 'other value'
        d = StringDict()
        d['update'] = "updated"  # here cast not needed
        self.dic.update(d)
        printf("modified content: %s\n", string_dict_repr(self.dic))



def main():
    cdef StringDict sdic

    orig_python_string_dict = {
        b'alpha': b'bytes alpha',
        'beta': 'Zoé',
        'gamma': 'trois',
        'delta': 'quatre',
        'epsilon': ''
    }

    print('Start')
    sdic = to_string_dict(orig_python_string_dict)

    # test the from_ on initial value:
    python_dict_init = from_string_dict(sdic)

    with nogil:  # starting in nogil to see if how to pass arguments
        demo = DemoStringDict(sdic)
        demo.print_demo()

    # try return data (with gil)
    python_dict_sdic = from_string_dict(sdic)
    python_dict_result = from_string_dict(demo.dic)
    print('in "python/gil" perimeter:')
    print("  - initial dict:", python_dict_init)
    print("  - parameter dict:", python_dict_sdic)
    print("(So the parameter dict was modified in place)")
    print("  - modified dict:", python_dict_result)
    # result is ok with del_item fix of 21sept
    print()
    print("The end.")
