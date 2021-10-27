# distutils: language = c++
from libcpp.limits cimport numeric_limits
from stdlib.fmt cimport printf


cdef unsigned long long factorial(unsigned long long n) nogil:
    cdef unsigned long long a, i

    if n <= 1:
        return 1
    a = 1
    for i in range(2, n + 1):
        a = a * i
    return a


def main():

    # if numeric_limits[ulong].digits() <= 32:
    #     max_val = 12
    # else:
    #     max_val = 20
    cdef unsigned long long max_val, n

    max_val = 20
    with nogil:
        for n in range(max_val + 1):
            printf("factorial(%d): %d\n", n, factorial(n))
        printf("overflow:\n")
        printf("factorial(%d): %d\n", max_val + 1, factorial(max_val + 1))
