# distutils: language = c++
"""
Cython+ experiment with cyplist / scalar char
(using syntax of september 2021)
"""
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf

from libcythonplus.list cimport cyplist


# we make experiment with always the same type:
ctypedef cyplist[unsigned char] CharLst


# some utility functions
cdef CharLst to_char_lst(python_list):
    """create a CharLst instance from standard python list

    (need gil)
    """
    cdef unsigned char c
    lst = CharLst()
    for s in python_list:
        c = <unsigned char> s.encode("utf8")[0]  # keep only first char if wchar utf8...
        lst.append(c)
    return lst


cdef list char_lst_to_python_list(CharLst char_lst):
    """use chr() to convert CharLst to python

    (need gil)
    """
    return [chr(i) for i in char_lst]


cdef string char_list_repr(CharLst lst) nogil:
    """Some kind of __repr__ for CharLst type

    (nogil)
    """
    cdef string result = string("CharLst([")
    cdef bint first_one = True

    for item in lst:
        s = sprintf("%c", item)
        if result.size() + s.size() > 70:
            result = sprintf("%s,...", result)
            break
        if first_one:
            result = sprintf("%s%s", result, s)
            first_one = False
        else:
            result = sprintf("%s, %s", result, s)
    result = sprintf("%s])", result)
    return result



cdef cypclass DemoListChar:
    """A demo cypclass, to experiment how to stay as long as possible in the nogil
    perimeter

    - demo of a cyplist using scalar "unsigned char"
    """
    CharLst lst

    __init__(self, CharLst param_lst):  # remember: no default parameter allowed
        self.lst = param_lst

    void print_demo(self):
        """method executed with nogil status
        """
        # printf("len(lst):  %d\n", len(self.lst))        # pb: this requires the GIL
        printf("lst.__len__:  %d\n", self.lst.__len__())  # but this is ok !
        printf("lst content: %s\n", char_list_repr(self.lst))   # using hand made repr()

        #### make some operation
        self.lst[1] += 1  # here cast not needed
        self.lst[2] = self.lst[2] + 2  # here cast not needed
        self.lst[3] = 'z'  # here cast not needed

        new_lst = CharLst()
        for i in self.lst:
            # Mandatory to cast everywhere in append() to keep nogil status:
            new_lst.append(<unsigned char> i + <unsigned char> 26)

        self.lst = new_lst
        printf("modified content: %s\n", char_list_repr(self.lst))

    CharLst get_list(self):
        return self.lst

    # @property not working ?
    CharLst double_list(self):
        return self.lst * 2



def main():
    # possibly utf8 long chars...
    orig_list = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N']

    print('Start')
    lst = to_char_lst(orig_list)

    with nogil:  # starting in nogil to see if how to pass arguments
        demo = DemoListChar(lst)
        # and now some "print" demo:
        demo.print_demo()

    # try return data (with gil)
    lst = demo.get_list()
    # print("returned CharLst:", lst)  # error: need to convert to python
    python_lst = char_lst_to_python_list(lst)  # this to convert to python objects
    print('Returned list in "python/gil" perimeter:', python_lst)

    dbl_list = char_lst_to_python_list(demo.double_list())
    print('Returned double list in "python/gil" perimeter:', dbl_list)

    print()
    print("The end.")
