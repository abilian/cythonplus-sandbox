# distutils: language = c++
"""
Cython+ exemple, cypdict minimal exemple
(using syntax of september 2021)
"""
from libcythonplus.dict cimport cypdict
from stdlib.string cimport string
from stdlib.fmt cimport printf


# define a specialized type: dict of string keys and long values
ctypedef cypdict[string, long] LongDict


cdef void demo_cypdict():
    cdef LongDict dic, dic2

    dic = LongDict()
    dic2 = LongDict()
    with nogil:
        dic["alpha"] = 10
        dic["beta"] = 20
        dic["gamma"] = 30
        dic["delta"] = 40

        dic2["one"] = 1
        dic2["two"] = 2

        printf("dic.__len__(): %d\n", dic.__len__())

        printf("'beta' in dic: %d\n", string("beta") in dic)

        dic["another"] = 50
        printf("dic['another']: %ld\n", <long> dic["another"])

        del dic["delta"]
        dic.update(dic2)
        for item in dic.items():
            printf("%s:%ld  ", item.first, <long> item.second)
        printf("\n")

        printf("keys: ")
        for k in dic.keys():
            printf("%s  ", k)
        printf("\n")

        printf("values: ")
        for v in dic.values():
            printf("%ld  ", <long> v)
        printf("\n")


def main():
    demo_cypdict()
