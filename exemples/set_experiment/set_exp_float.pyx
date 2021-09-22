# distutils: language = c++
"""
Cython+ experiment with cypset / double
(using syntax of september 2021)
"""
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf

from libcythonplus.set cimport cypset

# we make experiment with always the same type:
ctypedef cypset[double] FloatSet


cdef FloatSet to_float_set(python_iterable):
    """create a FloatSet instance from a float python iterable

    (need gil)
    """
    s = FloatSet()
    for i in python_iterable:
        s.add(<double> i)
    return s


cdef set from_float_set(FloatSet s):
    """create a python set instance from a FloatSet

    (need gil)
    """
    return {i for i in s}


cdef string float_set_repr(FloatSet fset) nogil:
    """Some kind of __repr__ for FloatSet type

    (nogil)
    """
    cdef string result = string("FloatSet({")
    cdef bint first_one = True
    cdef double i  # warn: here we need to cdzf the variable

    for i in fset:
        s = sprintf("%.6f", i)
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



cdef cypclass DemoFloatSet:
    """A demo cypclass, to experiment how to stay as long as possible in the nogil
    perimeter

    - demo of a cypset using scalars: FloatSet
    """
    FloatSet fset

    __init__(self, FloatSet param_set):  # remember: no default parameter allowed
        self.fset = param_set

    void print_demo(self):
        """method executed with nogil status
        """
        printf("set.__len__:  %d\n", self.fset.__len__())
        printf("set content: %s\n", float_set_repr(self.fset))  # using hand made repr()

        #### make some basic operations
        self.fset.add(100)  # try an int
        self.fset.add(50.1)
        self.fset.add(1.3)  # add existing
        self.fset.discard(420.5)  # discard non existing
        self.fset.discard(-1000.0)
        x = 0.0
        printf("%f is in set: %d\n", x, x in self.fset)
        s2 = FloatSet()
        s2.add(2.5)
        self.fset.update(s2)
        printf("modified content: %s\n", float_set_repr(self.fset))



def main():
    cdef FloatSet fset

    orig_python_float_set = {0.0, 1.3, -1000.0}

    print('Start')
    fset = to_float_set(orig_python_float_set)

    # test the from_ on initial value:
    python_set_init = from_float_set(fset)

    with nogil:  # starting in nogil to see if how to pass arguments
        demo = DemoFloatSet(fset)
        demo.print_demo()

    # try return data (with gil)
    python_param_set = from_float_set(fset)
    python_set_result = from_float_set(demo.fset)
    print('in "python/gil" perimeter:')
    print("  - initial set:", python_set_init)
    print("  - parameter set:", python_param_set)
    print("(So the parameter set was modified in place)")
    print("  - result set:", python_set_result)
    # result is ok with del_item fix of 21sept
    print()
    print("The end.")
