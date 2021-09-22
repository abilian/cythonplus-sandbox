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


cdef LongDict to_long_dict(python_dict):
    """create a LongDict instance from a str/int python dict or
    a bytes/int

    (need gil)
    """
    dic = LongDict()
    for k, v in python_dict.items():
        # some error to not have: "Casting temporary Python object to non-numeric non-Python type"
        if isinstance(k, str):
            sk = string(bytes(k.encode("utf8")))
        else:
            sk = string(bytes(k))
        dic[sk] = <long> v
    return dic


cdef dict from_long_dict(LongDict dic):
    """create a python dict instance from a LongDict

    (need gil)
    """
    return {i.first.decode("utf8", 'replace'): i.second for i in dic.items()}


cdef string long_dict_repr(LongDict dic) nogil:
    """Some kind of __repr__ for LongDict type

    (nogil)
    """
    cdef string result = string("LongDict({")
    cdef bint first_one = True

    for item in dic.items():
        s = sprintf("%s:%d", item.first, <long> item.second)
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



cdef cypclass DemoLongDict:
    """A demo cypclass, to experiment how to stay as long as possible in the nogil
    perimeter

    - demo of a cypdict using scalars: LongDict
    """
    LongDict dic

    __init__(self, LongDict param_dic):  # remember: no default parameter allowed
        self.dic = param_dic

    void print_demo(self):
        """method executed with nogil status
        """
        printf("dic.__len__:  %d\n", self.dic.__len__())
        printf("dict content: %s\n", long_dict_repr(self.dic))  # using hand made repr()

        #### make some operations
        self.dic['alpha'] += 111  # here cast not needed
        # and hope we catch the b'alpha'
        self.dic['beta'] = self.dic['beta'] + 2000  # here cast not ne
        self.dic['gamma'] = 5000  # here cast not needed
        del self.dic['delta']
        self.dic['other'] = 1010
        d = LongDict()
        d['update'] = 555
        self.dic.update(d)
        printf("modified content: %s\n", long_dict_repr(self.dic))



def main():
    cdef LongDict ldic

    orig_python_long_dict = {
        b'alpha': 1,
        'beta': 2,
        'gamma': 3,
        'delta': 4,
        'epsilon': 5}

    print('Start')
    ldic = to_long_dict(orig_python_long_dict)

    # test the from_ on initial value:
    python_dict_init = from_long_dict(ldic)

    with nogil:  # starting in nogil to see if how to pass arguments
        demo = DemoLongDict(ldic)
        demo.print_demo()

    # try return data (with gil)
    python_dict_ldic = from_long_dict(ldic)
    python_dict_result = from_long_dict(demo.dic)
    print('in "python/gil" perimeter:')
    print("  - initial dict:", python_dict_init)
    print("  - parameter dict:", python_dict_ldic)
    print("(So the parameter dict was modified in place)")
    print("  - modified dict:", python_dict_result)
    # result is ok with del_item fix of 21sept
    print()
    print("The end.")
