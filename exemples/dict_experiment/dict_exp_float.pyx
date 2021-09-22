# distutils: language = c++
"""
Cython+ experiment with cypdict / string/double
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


cdef FloatDict to_float_dict(python_dict):
    """create a LongDict instance from a str/double python dict

    (need gil)
    """
    dic = FloatDict()
    for k, v in python_dict.items():
        # some error to not have: "Casting temporary Python object to non-numeric non-Python type"
        if isinstance(k, str):
            sk = string(bytes(k.encode("utf8")))
        else:
            sk = string(bytes(k))
        dic[sk] = <double> v
    return dic


cdef dict from_float_dict(FloatDict dic):
    """create a python dict instance from a FloatDict

    (need gil)
    """
    return {i.first.decode("utf8", 'replace'): i.second for i in dic.items()}


cdef string float_dict_repr(FloatDict dic) nogil:
    """Some kind of __repr__ for FloatDict type

    (nogil)
    """
    cdef string result = string("FloatDict({")
    cdef bint first_one = True

    for item in dic.items():
        s = sprintf("%s:%.6f", item.first, <double> item.second)
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



cdef cypclass DemoFloatDict:
    """A demo cypclass, to experiment how to stay as long as possible in the nogil
    perimeter

    - demo of a cypdict using scalars: FloatDict
    """
    FloatDict dic

    __init__(self, FloatDict param_dic):  # remember: no default parameter allowed
        self.dic = param_dic

    void print_demo(self):
        """method executed with nogil status
        """
        printf("dic.__len__:  %d\n", self.dic.__len__())
        printf("dict content: %s\n", float_dict_repr(self.dic))  # using hand made repr()

        #### make some operations
        self.dic['alpha'] += 1.23456  # here cast not needed
        # and hope we catch the b'alpha'
        self.dic['beta'] = self.dic['beta'] - 1000   # here cast not ne
        self.dic['gamma'] = 5e20  # here cast not needed
        del self.dic['delta']
        self.dic['other'] = 3.1415926536
        d = FloatDict()
        d['update'] = 42
        self.dic.update(d)
        printf("modified content: %s\n", float_dict_repr(self.dic))



def main():
    cdef FloatDict ldic

    orig_python_float_dict = {
        b'alpha': 0.0,
        'beta': 2.0,
        'gamma': 3.333333333333,
        'delta': 4,
        'epsilon': 5}

    print('Start')
    ldic = to_float_dict(orig_python_float_dict)

    # test the from_ on initial value:
    python_dict_init = from_float_dict(ldic)

    with nogil:  # starting in nogil to see if how to pass arguments
        demo = DemoFloatDict(ldic)
        demo.print_demo()

    # try return data (with gil)
    python_dict_ldic = from_float_dict(ldic)
    python_dict_result = from_float_dict(demo.dic)
    print('in "python/gil" perimeter:')
    print("  - initial dict:", python_dict_init)
    print("  - parameter dict:", python_dict_ldic)
    print("(So the parameter dict was modified in place)")
    print("  - modified dict:", python_dict_result)
    # result is ok with del_item fix of 21sept
    print()
    print("The end.")
