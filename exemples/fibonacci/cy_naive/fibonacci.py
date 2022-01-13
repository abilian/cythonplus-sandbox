#!/usr/bin/env python
# Fibonacci x 100, cython naive (original pure python used as cython source)
# for "int" on 64bits fibonacci max is n: 92 fibo: 7540113804746346429
# (for fib(n) <= 2**63)
# So for testing purpose, use "float" (aka double) fibonacci max is about 1477


def fibo(n):
    a = 0.0
    b = 1.0
    for i in range(n):
        a, b = b, a + b
    return a


def fibo_list(size):
    results = []
    # store each result, or for the C versions the clever compiler will not
    # compute unused results
    for i in range(size + 1):
        results.append(fibo(i))
    return results


def print_summary(sequence):
    for idx in (0, 1, -1):
        print(f"{idx}: {sequence[idx]:.1f}, ")


def main(size=None):
    if not size:
        size = 1476
    print_summary(fibo_list(int(size)))


def fibo_many(size=None, repeat=100):
    if not size:
        size = 1476
    size = int(size)
    many = []
    for i in range(repeat):
        many.append(fibo_list(size))


if __name__ == "__main__":
    main()
