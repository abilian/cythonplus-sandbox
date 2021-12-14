# distutils: language = c++
from libc.stdio cimport printf, puts
from libc.time cimport time_t, time
from libcythonplus.dict cimport cypdict
from stdlib._string cimport string
from stdlib.string cimport Str
from stdlib.format cimport format

from .stdlib.abspath cimport abspath
from .stdlib.startswith cimport startswith, endswith
from .stdlib.strip cimport stripped
from .stdlib.regex cimport re_is_match
from .stdlib.formatdate cimport formatdate
from .stdlib.parsedate cimport parsedate

from .common cimport Sdict, getdefault, StrList, Finfo, Fdict
from .http_status cimport get_status_line
from .http_headers cimport HttpHeaders, py_environ_headers, make_header
from .media_types cimport MediaTypes
from .scan cimport scan_fs_dic
from .response cimport Response
from .static_file cimport StaticFile


cdef void test_http_status():
    cdef string s
    puts("HttpStatusDict:")
    s = get_status_line(Str("OK"))
    print(s.c_str())
    s = get_status_line(Str("NOT_MODIFIED"))
    print(s.c_str())


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
    cdef HttpHeaders hh, h2
    cdef Str resu
    cdef cypdict[string, string] str_headers,

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
    h2 = hh.copy()
    resu = h2.get_text()
    print("copy:", resu._str.c_str())
    print('env conversion:')
    env = {
        "REQUEST_METHOD": "GET",
        "QUERY_STRING": b"some bytes",
        "strange": [1, 2, 3]
        }
    str_headers = py_environ_headers(env)
    for item in str_headers.items():
        print(item.first.c_str(), item.second.c_str())
    print('--------------')
    hh = make_header(Str("Key"), Str("Value"))
    resu = hh.get_text()
    print("make_header:", resu._str.c_str())
    print('--------------')


cdef void test_mediatypes():
    cdef MediaTypes mt
    cdef Sdict extratypes = Sdict()

    mt = MediaTypes(extratypes)
    print(mt.get_type(Str("aaa")).bytes())
    print(mt.get_type(Str("bbb.css")).bytes())
    print(mt.get_type(Str("ccc.HTML")).bytes())


cdef void test_scan(Str root):
    cdef Fdict scanned
    cdef Finfo info
    # cdef Str x

    print("Scan:")
    print(root.bytes())
    scanned = scan_fs_dic(root)
    i = 0
    for item in scanned.items():
        i += 1
        if i > 10:
            return
        # x = Str(item.first.c_str())
        # print(x.bytes())
        print(item.first, item.second.size, item.second.mtime)


cdef test_formatdate():
    cdef time_t t = time(NULL)
    cdef time_t p
    cdef Str dt

    print("--------- formatdate ----------")
    dt = formatdate(t)
    print(dt._str)
    p = parsedate(dt)
    print(p)
    dt = formatdate(p)
    print(dt._str)


cdef test_response():
    cdef Response r

    # r = NOT_ALLOWED_RESPONSE
    print("-- responses: ---------")
    # print(r.status_line._str.c_str())
    # resu = r.headers.get_text()
    # print(resu._str.c_str())
    # if r.file_path:
    #     print(r.file_path._str.c_str())


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
    test_scan(root)
    test_formatdate()
    print("test format:", format("x: {:x}", 1234)._str)
    test_response()
