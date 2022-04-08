from libcythonplus.list cimport cyplist
from stdlib.string cimport Str, isspace
from stdlib._string cimport npos


cdef int replace_one(Str src, Str pattern, Str content) nogil:
    """Replace first occurence of 'pattern' in 'src' by 'content'.

    Return number of changes, Change in place.
    """
    cdef size_t start

    start = src.find(pattern)
    if start == npos:
        return 0
    src._str.replace(start, pattern.__len__(), content._str)
    return 1


cdef Str stripped(Str s) nogil:
    """return stripped string
    """
    cdef int start, end

    if s is NULL:
        return NULL
    if s._str.size() == 0:
        return Str("")
    start = 0
    end = s._str.size()
    while start < end and isspace(s[start]):
        start += 1
    while end > start and isspace(s[end - 1]):
        end -= 1
    if end <= start:
        return Str("")
    return s.substr(start, end)


cdef cyplist[Str] cypstr_split_tuple(Str tupl) nogil:
    """Split Tuple (Cython+ Str) into items.

    example::

         input : '[Geography].[Geography].[Continent].[Europe]'

         output : ['Geography', 'Geography', 'Continent', 'Europe']

    :param tupl: MDX Tuple as Cython+ Str
    :return: cyplist[Str] list of items
    """
    cdef cyplist[Str] lst

    lst = stripped(tupl).split(Str("].["))
    if lst.__len__() == 0:
        return lst
    replace_one(lst[0], Str("["), Str(""))
    replace_one(lst[lst.__len__() - 1], Str("]"), Str(""))
    return lst
