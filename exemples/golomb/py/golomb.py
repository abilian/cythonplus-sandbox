#!/usr/bin/env python
# golomb sequence


def g(n):
    if n == 1:
        return 1
    return g(n - g(g(n - 1))) + 1


def golomb_sequence(size):
    return [(i, g(i)) for i in range(1, size + 1)]


def main(size=None):
    if not size:
        size = 50
    print(golomb_sequence(int(size)))


if __name__ == "__main__":
    import sys

    main(sys.argv[1])
