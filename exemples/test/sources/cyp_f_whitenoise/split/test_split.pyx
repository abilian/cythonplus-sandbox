# distutils: language = c++
from libc.stdio cimport printf, puts
from stdlib.string cimport Str

from .stdlib.abspath cimport abspath
from .stdlib.startswith cimport startswith, endswith
from .stdlib.strip cimport stripped
from .stdlib.regex cimport re_is_match

from .common cimport Sdict, getdefault, StrList
from .http_status cimport HttpStatus, HttpStatusDict, generate_http_status_dict
from .http_headers cimport HttpHeaders
from .media_types cimport MediaTypes


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


cdef void test_stripped():
    cdef Str s, s2
    cdef Str t = Str("-")

    s = Str("bold")
    s2 = t + s + t + Str("   ") + t + stripped(s) + t
    print(s2.bytes())

    s = Str("right  ")
    s2 = t + s + t + Str("   ") + t + stripped(s) + t
    print(s2.bytes())

    s = Str("  left")
    s2 = t + s + t + Str("   ") + t + stripped(s) + t
    print(s2.bytes())

    s = Str("    both  ")
    s2 = t + s + t + Str("   ") + t + stripped(s) + t
    print(s2.bytes())

    s = Str("      ")
    s2 = t + s + t + Str("   ") + t + stripped(s) + t
    print(s2.bytes())



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


cdef void test_HttpHeaders():
    cdef HttpHeaders hh
    cdef Str resu

    hh = HttpHeaders()
    print("HttpHeaders:")
    empty = hh.get_text().bytes()
    print("empty:", empty)

    hh.set(Str("SomeKey"), Str("SomeValue1"))
    resu = hh.get_text()
    print("v1:", resu._str.c_str())

    hh.append(Str("AnotherKey "), Str("SomeValue2"))
    hh.append(Str("AnotherKey"), Str("SomeValue3"))
    hh.append(Str("thirdkey"), Str(" CCCCCC"))
    resu = hh.get_text()
    print("v2:", resu._str.c_str())

    resu = hh.get_content(Str("AnotherKey"))
    print("v3:", resu._str.c_str())

    hh.set(Str("SomeKey"), Str("Other"))
    hh.remove(Str("AnotherKey"))
    resu = hh.get_text()
    print("v4:", resu._str.c_str())


cdef void test_mediatypes():
    cdef MediaTypes mt
    cdef Sdict extratypes = Sdict()

    mt = MediaTypes(extratypes)
    print(mt.get_type(Str("aaa")).bytes())
    print(mt.get_type(Str("bbb.css")).bytes())
    print(mt.get_type(Str("ccc.HTML")).bytes())


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
    test_stripped()
    test_HttpHeaders()
    test_mediatypes()
