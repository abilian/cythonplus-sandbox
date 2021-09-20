# distutils: language = c++
"""
Cython+ experiment with cyplist / sting class (and char split)
(using syntax of september 2021)
"""
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf

from libcythonplus.list cimport cyplist


# we make experiment with always the same types:
ctypedef cyplist[string] StrLst
ctypedef cyplist[unsigned char] CharLst


# some utility functions
cdef StrLst to_string_lst(python_list):
    """create a StrLst instance from standard python list

    (need gil)
    """
    lst = StrLst()
    for ps in python_list:
        lst.append(string(bytes(ps.encode("utf8"))))  # hack: cast to bytes, or no compile
    return lst


cdef list string_lst_to_python_list(StrLst lst):
    """convert StrLst to python

    (need gil)
    """
    return [i.decode("utf8") for i in lst]


cdef string str_list_repr(StrLst lst) nogil:
    """Some kind of __repr__ for StrLst type

    (nogil)
    """
    cdef string result = string("StrLst([")
    cdef bint first_one = True

    for s in lst:
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



cdef cypclass DemoListStringChar:
    """A demo cypclass, to experiment how to stay as long as possible in the nogil
    perimeter

    - demo of a cyplist using instances of string
    """
    StrLst lst

    __init__(self, StrLst param_lst):  # remember: no default parameter allowed
        self.lst = param_lst

    void print_demo(self):
        """method executed with nogil status
        """
        # printf("len(lst):  %d\n", len(self.lst))        # pb: this requires the GIL
        printf("lst.__len__:  %d\n", self.lst.__len__())  # but this is ok !
        printf("lst content: %s\n", str_list_repr(self.lst))   # using hand made repr()

        #### make some operation
        # self.lst[2] = self.lst[2] + string('_c')  # not possible
        # self.lst[2] = sprintf("%s%s", self.lst[2], string('_c'))  # no, need string cast
        self.lst[2] = sprintf("%s%s", string(self.lst[2]), string('_b'))
        self.lst[3] = string('zzé')

        new_lst = StrLst()
        for s in self.lst:
            new_lst.append(sprintf("__%s__", s))

        self.lst = new_lst
        printf("modified content: %s\n", str_list_repr(self.lst))
        printf("\n")

    StrLst get_list(self):
        return self.lst

    # @property not working ?
    StrLst double_list(self):
        return self.lst * 2

    void string_to_list_of_char(self, int index):
        printf("Copy a string as a list of chars (%d):\n", index)
        char_lst = CharLst()
        s = self.lst[index]
        printf("%s\n", string(s))  # need string cast....
        for c in s:
            char_lst.append(c)
        printf("%s\n", char_list_repr(char_lst))
        printf("\n")

    CharLst return_string_to_list_of_char(self, int index):
        char_lst = CharLst()
        s = self.lst[index]
        for c in s:
            char_lst.append(c)
        return char_lst


def main():
    # possibly utf8
    orig_list = ['&£ùéà', 'Alpha', 'Beta', 'Gamma', 'Delta']

    print('Start')
    lst = to_string_lst(orig_list)

    with nogil:  # starting in nogil to see if how to pass arguments
        demo = DemoListStringChar(lst)

        with gil:
            lst = demo.get_list()
            python_lst = string_lst_to_python_list(lst)  # this to convert to python objects
            print('initial list back in "python/gil" perimeter:', python_lst)
        # and now some "print" demo:
        demo.print_demo()
        demo.string_to_list_of_char(0)
        demo.string_to_list_of_char(1)
        demo.string_to_list_of_char(2)

    # try return data (with gil)
    lst = demo.get_list()
    python_lst = string_lst_to_python_list(lst)  # this to convert to python objects
    print('Returned list in "python/gil" perimeter:', python_lst)

    dbl_list = string_lst_to_python_list(demo.double_list())
    print('Returned double list in "python/gil" perimeter:', dbl_list)

    char_lst = char_lst_to_python_list(demo.return_string_to_list_of_char(1))
    print()
    print('Returned list of char in "python/gil" perimeter:', char_lst)

    print()
    print("The end.")
