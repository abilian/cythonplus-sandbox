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


# some utility functions
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



cdef cypclass DemoDict:
    """A demo cypclass, to experiment how to stay as long as possible in the nogil
    perimeter

    - demo of a cypdict using scalars
    """
    NumDict dic

    __init__(self, NumDict param_dic):  # remember: no default parameter allowed
        self.dic = param_dic

    void print_demo(self):
        """method executed with nogil status
        """
        printf("dic.__len__:  %d\n", self.dic.__len__())  # but this is ok !
        printf("dict content: %s\n", num_dict_repr(self.dic))   # using hand made repr()

        #### make some operations
        self.dic[1] += 111  # here cast not needed
        self.dic[2] = self.dic[2] + 2000  # here cast not needed
        self.dic[3] = 5000  # here cast not needed
        del self.dic[4]
        self.dic[10] = 1010

        d = NumDict()
        d[55] = 555
        self.dic.update(d)

        printf("modified content: %s\n", num_dict_repr(self.dic))

    NumDict get_num_dict(self):
        return self.dic


def main():
    cdef NumDict dic

    orig_num_dict = {0:0, 1:1, 2:1, 3:2, 4:3, 5:5, 6:8}

    print('Start')
    dic = to_num_dict(orig_num_dict)

    with nogil:  # starting in nogil to see if how to pass arguments
        # with gil:
        demo = DemoDict(dic)
        # and now some "print" demo:
        demo.print_demo()

    # try return data (with gil)
    python_dic = {item.first:item.second for item in dic.items()}
    print('Returned dict in "python/gil" perimeter:', python_dic)
    print('(result is not correct at the moment, search in progress...)')

    print()
    print("The end.")
