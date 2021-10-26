# distutils: language = c++
from libcpp.limits cimport numeric_limits
from stdlib.fmt cimport printf

cdef unsigned long long factorial(unsigned long long n) nogil:
    cdef unsigned long long a = 1


    if n <= 1:
        return 1
    if numeric_limits[ULONGLONG].digits() <= 32:
        if n > 12:
            with gil:
                raise ValueError(f"Factorial will overflow: {n}")
    elif numeric_limits[ulonglong].digits() <= 64:
        if n > 20:
            with gil:
                raise ValueError(f"Factorial will overflow: {n}")
    for i in range(2, n + 1):
        a *= 2
    return a


def main():
    with nogil:
        for n in range(21):
            printf("factorial(%d): %d\n", n, factorial(n))
