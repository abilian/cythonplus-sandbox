# distutils: language = c++
from libc.stdio cimport printf, puts
from stdlib._string cimport string
from stdlib.string cimport Str

from .abspath cimport abspath
from .startswith cimport startswith, endswith
from stdlib.regex cimport regex_t, regmatch_t, regcomp, regexec, regfree
from stdlib.regex cimport REG_EXTENDED

from .http_status cimport HttpStatus, HttpStatusDict, generate_http_status_dict


cdef bint re_match(Str pattern, Str target) nogil:
    cdef regex_t regex
    cdef int result
    # cdef regmatch_t  pmatch[1]

    if regcomp(&regex, pattern.bytes(), REG_EXTENDED):
        with gil:
            raise ValueError(f"regcomp failed on {pattern.bytes()}")

    if not regexec(&regex, target.bytes(), 0, NULL, 0):
        return 1
    return 0

cdef void test_http_status():
    cdef HttpStatusDict hsd
    cdef HttpStatus s

    hsd = generate_http_status_dict()
    puts("HttpStatusDict:")
    print(hsd.__len__())
    s = hsd[Str("OK")]
    print(s.status_line().bytes())


def main():
    root = abspath(Str("."))
    print("split2")
    print("endswith :", endswith(root, Str('/build')))
    print("endswith :", endswith(root, Str('toto')))
    print("startswith :", startswith(Str("abc"), Str('ab')))
    print("startswith :", startswith(root, Str('toto')))
    print("regex :", re_match(Str("abc"), Str("cccccabccccc")))
    print("regex :", re_match(Str("abcxxx"), Str("cccccabccccc")))
    test_http_status()
