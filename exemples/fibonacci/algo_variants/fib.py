#!/usr/bin/env python

# max is n: 92 fibo: 7540113804746346429  (for fib(n) <= 2**63)
import sys

# from functools import lru_cache
from math import log2


# @lru_cache
def fib(n):
    if n < 2:
        return n
    return fib(n - 1) + fib(n - 2)


fcache = {0: 0, 1: 1}


def fib_with_fcache(n):
    # limiting the need of recursion
    if n not in fcache:
        for i in range(2, n + 1):
            if i not in fcache:
                fcache[i] = fcache[i - 1] + fcache[i - 2]
    return fcache[n]


def limit_long():
    """search max n with fibo(n) <= 2**63"""
    result = 0
    nok = 0
    while True:
        n = nok + 1
        if fib2(n) > 2 ** 63:
            print("max is n:", nok, "fibo:", fib2(nok))
            return
        else:
            nok = n


def fibab(n):
    a = 0
    b = 1
    for i in range(n):
        a, b = b, a + b
    return a


def fab_250k():
    for i in range(250_000):
        x = fibab(92)
    return x


def f2_250k():
    for i in range(250_000):
        x = fib_with_fcache(92)
    return x


if __name__ == "__main__":
    # print(fib2(int(sys.argv[1])))
    # print(log2(fib2(int(sys.argv[1]))))
    limit_long()
