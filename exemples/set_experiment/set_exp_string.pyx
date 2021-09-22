# distutils: language = c++
"""
Cython+ experiment with cypset / string
(using syntax of september 2021)
"""
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf

from libcythonplus.set cimport cypset

# we make experiment with always the same type:
ctypedef cypset[string] StringSet


cdef StringSet to_string_set(python_iterable):
    """create a StringSet instance from a python iterable of strings

    (need gil)
    """
    sset = StringSet()
    for i in python_iterable:
        if isinstance(i, str):
           sset.add(string(bytes(i.encode("utf8"))))
        else:
           sset.add(string(bytes(i)))
    return sset


cdef set from_string_set(StringSet sset):
    """create a python set instance from a StringSet

    (need gil)
    """
    return {e.decode("utf8", 'replace') for e in sset}


cdef string string_set_repr(StringSet sset) nogil:
    """Some kind of __repr__ for StringSet type

    (nogil)
    """
    cdef string result = string("StringSet({")
    cdef bint first_one = True

    for element in sset:
        s = sprintf("%s", element)
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



cdef cypclass DemoStringSet:
    """A demo cypclass, to experiment how to stay as long as possible in the nogil
    perimeter

    - demo of a cypset using scalars: StringSet
    """
    StringSet sset

    __init__(self, StringSet param_set):  # remember: no default parameter allowed
        self.sset = param_set

    void print_demo(self):
        """method executed with nogil status
        """
        printf("set.__len__:  %d\n", self.sset.__len__())
        printf("set content: %s\n", string_set_repr(self.sset))  # using hand made repr()

        #### make some basic operations
        self.sset.add("added")
        self.sset.add(string("added"))
        self.sset.add("alpha")  # add existing
        self.sset.discard("ghost")  # discard non existing
        self.sset.discard("gamma")
        x = string("beta")
        printf("%s is in set: %d\n", x, x in self.sset)
        set2 = StringSet()
        set2.add("another")
        self.sset.update(set2)
        printf("modified content: %s\n", string_set_repr(self.sset))



def main():
    cdef StringSet sset

    orig_python_string_set = {b"alpha", "", "beta", "gamma"}

    print('Start')
    sset = to_string_set(orig_python_string_set)

    # test the from_ on initial value:
    python_set_init = from_string_set(sset)

    with nogil:  # starting in nogil to see if how to pass arguments
        demo = DemoStringSet(sset)
        demo.print_demo()

    # try return data (with gil)
    python_param_set = from_string_set(sset)
    python_set_result = from_string_set(demo.sset)
    print('in "python/gil" perimeter:')
    print("  - initial set:", python_set_init)
    print("  - parameter set:", python_param_set)
    print("(So the parameter set was modified in place)")
    print("  - result set:", python_set_result)
    # result is ok with del_item fix of 21sept
    print()
    print("The end.")
