# distutils: language = c++
"""
Cython+ experiment with cyplist / scalar long long
(using syntax of september 2021)
"""
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf

from libcythonplus.list cimport cyplist


# we make experiment with always the same type:
ctypedef cyplist[long long] LongLst


# some utility functions
cdef LongLst to_long_lst(python_list):
    """create a LongLst instance from standard python list

    (need gil)
    """
    cdef long long lx
    lst = LongLst()
    for x in python_list:
        lx = <long long> x
        lst.append(lx)
    return lst


cdef string list_repr(LongLst lst) nogil:
    """Some kind of __repr__ for LongLst type

    (nogil)
    """
    cdef string result = string("LongLst([")
    cdef bint first_one = True

    for item in lst:
        s = sprintf("%d", item)
        if result.size() + s.size() > 40:
            result = sprintf("%s,...", result)
            break
        if first_one:
            result = sprintf("%s%s", result, s)
            first_one = False
        else:
            result = sprintf("%s, %s", result, s)
    result = sprintf("%s])", result)
    return result



cdef cypclass DemoListLongLong:
    """A demo cypclass, to experiment how to stay as long as possible in the nogil
    perimeter

    - demo of a cyplist using scalar "long long"
    """
    LongLst lst

    __init__(self, LongLst param_lst):  # remember: no default parameter allowed
        self.lst = param_lst

    void print_demo(self):
        """method executed with nogil status
        """
        # printf("len(lst):  %d\n", len(self.lst))        # pb: this requires the GIL
        printf("lst.__len__:  %d\n", self.lst.__len__())  # but this is ok !
        printf("lst content: %s\n", list_repr(self.lst))   # using hand made repr()

        #### make some operation
        self.lst[1] += 111  # here cast not needed
        self.lst[2] = self.lst[2] + 2000  # here cast not needed
        self.lst[3] = 5000  # here cast not needed

        new_lst = LongLst()
        for i in self.lst:
            # Mandatory to cast everywhere in append() to keep nogil status:
            new_lst.append(<long long> i * <long long> 2)

        self.lst = new_lst
        printf("modified content: %s\n", list_repr(self.lst))

    LongLst get_list(self):
        return self.lst

    # @property not working ?
    LongLst double_list(self):
        return self.lst * 2



def main():
    orig_list = [10, 20, 30, 40, 50, 60]

    print('Start')
    lst = to_long_lst(orig_list)

    with nogil:  # starting in nogil to see if how to pass arguments
        demo = DemoListLongLong(lst)
        # and now some "print" demo:
        demo.print_demo()

    # try return data (with gil)
    lst = demo.get_list()
    # print("returned LongLst:", lst)  # error: need to convert to python
    python_lst = [i for i in lst]  # this to convert to python objects
    print('Returned list in "python/gil" perimeter:', python_lst)

    dbl_list = [i for i in demo.double_list()]
    print('Returned double list in "python/gil" perimeter:', dbl_list)

    print()
    print("The end.")
