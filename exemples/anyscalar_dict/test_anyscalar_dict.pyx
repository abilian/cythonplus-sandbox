# distutils: language = c++
"""
Cython+ experiment for abstract super class AnyScalar
(using syntax of september 2021)
"""
from stdlib.any_scalar cimport *
from stdlib.any_scalar import *
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf

from libcythonplus.dict cimport cypdict


ctypedef cypdict[string, AnyScalar] AnyScalarDict


cdef AnyScalarDict to_anyscalar_dict(python_dict):
    """create a AnyScalarDict instance from a str/* python dict

    (need gil)
    """
    asd = AnyScalarDict()
    for key, value in python_dict.items():
        if isinstance(key, str):
            string_key = string(bytes(key.encode("utf8")))
        else:
            string_key = string(bytes(key))
        # create the AnyScalar wrapper:
        asd[string_key] = python_to_any_scalar(value)
    return asd


cdef dict from_anyscalar_dict(AnyScalarDict dic):
    """create a python dict instance from a AnyScalarDict

    (need gil)
    """
    return {
        i.first.decode("utf8", 'replace'): any_scalar_to_python(i.second)
        for i in dic.items()
    }


cdef string anyscalar_dict_repr(AnyScalarDict dic) nogil:
    """Some kind of __repr__ for AnyScalarDict type

    (nogil)
    """
    cdef string result = string("AnyScalarDict({")
    cdef bint first_one = True

    for item in dic.items():
        s = sprintf("%s:%s", item.first, item.second.short_repr())
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



cdef cypclass DemoDict:
    """A demo cypclass, to experiment how to stay as long as possible in the nogil
    perimeter

    - demo of a cypdict using any scalars: AnyScalarDict
    """
    AnyScalarDict dic

    __init__(self, AnyScalarDict param_dic):  # remember: no default parameter allowed
        self.dic = param_dic

    void print_demo(self):
        """method executed with nogil status
        """
        printf("dic.__len__:  %d\n", self.dic.__len__())
        printf("dict content: %s\n", anyscalar_dict_repr(self.dic))


    # void print_demo(self):
    #     """method executed with nogil status
    #     """
    #     printf("dic.__len__:  %d\n", self.dic.__len__())
    #     printf("dict content: %s\n", string_dict_repr(self.dic))  # using hand made repr()
    #
    #     #### make some operations
    #     self.dic['alpha'] = string("new alpha")  # and hope we catch the b'alpha'
    #     # warn: here we need a cast:
    #     self.dic['beta'] = sprintf("%s%s", <string> self.dic['beta'], string(" more beta"))
    #     self.dic['gamma'] = string("three")  # here cast not needed
    #     del self.dic['delta']
    #     self.dic['other'] = 'other value'
    #     d = StringDict()
    #     d['update'] = "updated"  # here cast not needed
    #     self.dic.update(d)
    #     printf("modified content: %s\n", string_dict_repr(self.dic))



def main():
    cdef AnyScalarDict asd

    orig_python_dict = {
        b'alpha': b'bytes alpha',
        'beta': 'Zoé',
        'gamma': 1,
        'delta': 2.5,
    }

    print('Start')
    asd = to_anyscalar_dict(orig_python_dict)

    # test the "from_" on initial value:
    python_dict_init = from_anyscalar_dict(asd)

    with nogil:  # starting in nogil to see if how to pass arguments
        demo = DemoDict(asd)
        demo.print_demo()

    # try return data (with gil)
    python_dict_asd = from_anyscalar_dict(asd)
    python_dict_result = from_anyscalar_dict(demo.dic)
    print('in "python/gil" perimeter:')
    print("  - initial dict:", python_dict_init)
    print("  - parameter dict:", python_dict_asd)
    print("(So the parameter dict was modified in place)")
    print("  - modified dict:", python_dict_result)
    # result is ok with del_item fix of 21sept
    print()
    print("The end.")
