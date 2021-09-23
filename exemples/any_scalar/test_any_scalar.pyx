# distutils: language = c++
"""
Cython+ experiment for abstract super class AnyScalar
(using syntax of september 2021)
"""
from stdlib.any_scalar cimport *
from stdlib.any_scalar import *

def test_val(v):
    cdef AnyScalar a

    print("test", type(v), v, ':')
    a = python_to_any_scalar(v)
    print("repr:", a.repr())
    back = any_scalar_to_python(a)
    print("back:", type(back), back)
    print()


def main():
    cdef AnyScalar a1, a2

    print('Start')

    test_val(0)
    test_val(1)
    test_val(2**40)
    test_val(1.0)
    test_val(-5.1234)
    test_val("a")
    test_val("Zoé")
    test_val(b"Zoé")

    print()
    print("The end.")
