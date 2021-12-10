# distutils: language = c++
from libc.stdio cimport printf, puts
from stdlib.string cimport Str

from .stdlib.abspath cimport abspath
from .stdlib.startswith cimport startswith, endswith
from .stdlib.regex cimport re_is_match

from .common cimport Sdict, getdefault, StrList
from .http_status cimport HttpStatus, HttpStatusDict, generate_http_status_dict


cdef void test_http_status():
    cdef HttpStatusDict hsd
    cdef HttpStatus s

    hsd = generate_http_status_dict()
    puts("HttpStatusDict:")
    print(hsd.__len__())
    s = hsd[Str("OK")]
    print(s.status_line().bytes())


cdef void test_strlist():
    cdef StrList lst
    cdef Str s

    lst = StrList()
    lst.append(Str("a"))
    lst.append(Str("b"))
    print("StrList:")
    print(lst.__len__())
    print(Str("a") in lst)
    # for i in lst:
    for i in range(lst.__len__()):
        s = lst[i]
        puts(s._str.c_str())
        puts(s.bytes())


cdef void test_sdict():
    cdef Sdict d
    cdef Str s

    d = Sdict()
    d[Str("a")] = Str("A")
    d[Str("b")] = Str("B")
    d[Str("c")] = Str("C")
    del d[Str("c")]
    print("Sdict:")
    print(d.__len__())
    s = d[Str("b")]
    print(s.bytes())
    s = getdefault(d, Str("k"), Str("no k"))
    print(s.bytes())
    for i in d.items():
        puts(i.first.bytes())
        puts(i.second.bytes())
    for s in d.keys():
        puts(s.bytes())
    print(Str("a") in d)
    print(Str("x") in d)


def main():
    root = abspath(Str("."))
    print("split2")
    print("endswith :", endswith(root, Str('/build')))
    print("endswith :", endswith(root, Str('toto')))
    print("startswith :", startswith(Str("abc"), Str('ab')))
    print("startswith :", startswith(root, Str('toto')))
    print("regex :", re_is_match(Str("abc"), Str("cccccabccccc")))
    print("regex :", re_is_match(Str("abcxxx"), Str("cccccabccccc")))
    test_http_status()
    test_strlist()
    test_sdict()
