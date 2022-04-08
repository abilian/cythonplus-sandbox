from libcythonplus.list cimport cyplist
from stdlib.string cimport Str
from split_tuple cimport cypstr_split_tuple

def main():
    cdef Str input
    cdef cyplist[Str] result

    for tpl in (
        "",
        " ",
        "[]",
        "[",
        "]",
        "[aaa]",
        " [aaa].[bbb]\n",
        " \n [aaa].[bbb]  ",
        "[aaa].[b].[c c c] ",
        "[Geography].[Geography].[Continent].[Europe]"
        ):
            input = Str(tpl.encode("utf8", "replace"))
            result = cypstr_split_tuple(input)
            print(f"'{tpl}'", ":")
            for x in result:
                print(f"    '{x.bytes().decode('utf8')}'")
