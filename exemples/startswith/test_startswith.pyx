# distutils: language = c++
from stdlib.string cimport Str
from startswith cimport startswith, endswith

def main():
    for tpl in (
        ("ab", "abcd"),
        ("xxx", "abcd"),
        ("", "abcd"),
        ("abcd", "abcd"),
        ("abcde", "abcd"),
        ("abcde", ""),
        ):
        search, target = tpl
        print('startswith:', search, 'in', target, '->',
              startswith(Str(target.encode("utf8")), Str(search.encode("utf8"))))
    for tpl in (
        ("cd", "abcd"),
        ("xxx", "abcd"),
        ("", "abcd"),
        ("abcd", "abcd"),
        ("abcde", "abcd"),
        ("abcde", ""),
        ):
        search, target = tpl
        print('endswith:', search, 'in', target, '->',
              endswith(Str(target.encode("utf8")), Str(search.encode("utf8"))))
