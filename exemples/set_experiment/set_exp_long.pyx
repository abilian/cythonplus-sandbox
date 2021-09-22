# distutils: language = c++
"""
Cython+ experiment with cypset / long
(using syntax of september 2021)
"""
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf

from libcythonplus.set cimport cypset

# we make experiment with always the same type:
ctypedef cypset[long] LongSet


cdef LongSet to_long_set(python_iterable):
    """create a LongSet instance from a int python iterable

    (need gil)
    """
    s = LongSet()
    for i in python_iterable:
        s.add(<long> i)
    return s


cdef set from_long_set(LongSet s):
    """create a python set instance from a LongSet

    (need gil)
    """
    return {i for i in s}


cdef string long_set_repr(LongSet lset) nogil:
    """Some kind of __repr__ for LongSet type

    (nogil)
    """
    cdef string result = string("LongSet({")
    cdef bint first_one = True

    for item in lset:
        s = sprintf("%d", <long> item)
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



cdef cypclass DemoLongSet:
    """A demo cypclass, to experiment how to stay as long as possible in the nogil
    perimeter

    - demo of a cypset using scalars: LongSet
    """
    LongSet lset

    __init__(self, LongSet param_set):  # remember: no default parameter allowed
        self.lset = param_set

    void print_demo(self):
        """method executed with nogil status
        """
        printf("set.__len__:  %d\n", self.lset.__len__())
        printf("set content: %s\n", long_set_repr(self.lset))  # using hand made repr()

        #### make some basic operations
        self.lset.add(100)
        self.lset.add(1000)  # add existing
        self.lset.discard(420)  # discard non existing
        self.lset.discard(2000)
        s2 = LongSet()
        s2.add(5000)
        self.lset.update(s2)
        printf("modified content: %s\n", long_set_repr(self.lset))



def main():
    cdef LongSet lset

    orig_python_long_set = {1, 10, 1000, 2000}

    print('Start')
    lset = to_long_set(orig_python_long_set)

    # test the from_ on initial value:
    python_set_init = from_long_set(lset)

    with nogil:  # starting in nogil to see if how to pass arguments
        demo = DemoLongSet(lset)
        demo.print_demo()

    # try return data (with gil)
    python_param_set = from_long_set(lset)
    python_set_result = from_long_set(demo.lset)
    print('in "python/gil" perimeter:')
    print("  - initial set:", python_set_init)
    print("  - parameter set:", python_param_set)
    print("(So the parameter set was modified in place)")
    print("  - result set:", python_set_result)
    # result is ok with del_item fix of 21sept
    print()
    print("The end.")
