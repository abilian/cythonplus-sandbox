# distutils: language = c++
from stdlib.string cimport Str


cdef int replace_one(Str src, Str pattern, Str content) nogil:
    """Replace first occurence of 'pattern' in 'src' by 'content'.

    Change in place. If length of resulting string is bigger than original,
    increase the size of the result string as required.

    Return number of change.
    """
    cdef size_t start

    start = src.find(pattern)
    if start == src.__len__():
        return 0
    src._str.replace(start, pattern.__len__(), content._str)
    return 1


cdef int replace_all(Str src, Str pattern, Str content) nogil:
    """Replace all occurences of 'pattern' in 'src' by 'content'.
    """
    cdef size_t start, src_len
    cdef int count

    count = 0
    if pattern.__len__() == 0:
        return count
    src_len = src.__len__()
    if src_len == 0:
        return 0
    start = 0
    while 1:
        start = src.find(pattern, start)
        if start == src_len:
            return count
        src._str.replace(start, pattern.__len__(), content._str)
        start += content.__len__()


cdef void escape(Str src) nogil:
    """Escape '&', '<', and '>' in a string of data.

    Return NULL, change in place.
    """
    # must do ampersand first
    replace_all(src, Str("&"), Str("&amp;"))
    replace_all(src, Str(">"), Str("&gt;"))
    replace_all(src, Str("<"), Str("&lt;"))


# cdef void unescape(data, entities={}):
#     """Unescape &amp;, &lt;, and &gt; in a string of data.
#     You can unescape other strings of data by passing a dictionary as
#     the optional entities parameter.  The keys and values must all be
#     strings; each key will be replaced with its corresponding value.
#     """
#     data = data.replace("&lt;", "<")
#     data = data.replace("&gt;", ">")
#     if entities:
#         data = __dict_replace(data, entities)
#     # must do ampersand last
#     return data.replace("&amp;", "&")
