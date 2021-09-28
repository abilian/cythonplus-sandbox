# distutils: language = c++
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf
from aaa cimport *
from aaa import *

# hints:
# - for imported function in another pyx, declare a .pxd
# - always put the result of imported fct in a cdf variable


cdef string fba() nogil:
    cdef string a
    a = fa()
    return sprintf("%s b", a)

def main():
    print(fba().decode("utf8"))
