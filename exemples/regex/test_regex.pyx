# distutils: language = c++
from stdlib.string cimport Str
from stdlib.regex cimport regex_t, regmatch_t, regcomp, regexec, regfree
from stdlib.regex cimport REG_EXTENDED


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


def main():
    b = "[ :,;?()\"']"
    tests_lst = [
        ("xxx abc zzz", "abc", True),
        ("xxx abc zzz", "ABC", False),
        ("xxx abczzz", "abc", True),
        ("xxx abczzz", " abc", True),
        ("xxx abczzz", " abc ", False),
        ("xxx abczzz 1", "\\babc\\b", False),
        ("xxx abczzz 2 not supported", "\\babc", True),
        ("xxx abczzz 3 not supported", "\babc", True),
        ("xxx abczzz 4", "[ :,;?()\"']abc", True),
        ("xxx abczzz 5", b + "abc", True),
        ("xxx abczzz 6", b + "abc" + b, False),
    ]
    for target, pattern, expected in tests_lst:
        result = re_match(
            Str(pattern.encode("utf8")), Str(target.encode("utf8"))
        )
        print(repr(target),'/', repr(pattern), pattern.encode("utf8"), expected, '->', result)
        if result is not expected:
            print("some error ^^^^^")
