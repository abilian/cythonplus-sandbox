#!/usr/bin/env python
# golomb sequence, cython naive (original pure python used as cython source)


def gpos(n):
    """Return the value of position n of the Golomb sequence (recursive function)."""
    if n == 1:
        return 1
    return gpos(n - gpos(gpos(n - 1))) + 1


def golomb_sequence(size):
    return [(i, gpos(i)) for i in range(1, size + 1)]


def main(size=None):
    if not size:
        size = 50
    print(golomb_sequence(int(size)))


if __name__ == "__main__":
    import sys

    main(sys.argv[1])
