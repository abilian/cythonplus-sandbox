#!/usr/bin/env python
# for "int" on 64bits fibonacci max is n: 92 fibo: 7540113804746346429
# (for fib(n) <= 2**63)
# So for testing purpose, use "float" (aka double) fibonacci max is about 1477


def fibo(n):
    a = 0.0
    b = 1.0
    for x in range(n):
        a, b = b, a + b
    return a


def fibo_list(size):
    results = (
        []
    )  # store each result, or for the C versions the clever compiler will not
    # compute unused results
    for i in range(size):
        results.append(fibo(i))
    return results


if __name__ == "__main__":
    print(fibo_list(1477)[-10:])
