#!/usr/bin/env python
# golomb sequence

from transonic import boost

# __transonic def gpos(int)


@boost
def gpos(n: int) -> int:
    """Return the value of position n of the Golomb sequence (recursive function)."""
    val: int
    something: str

    val = 1
    if n == val:
        return 1
    return gpos(n - gpos(gpos(n - 1))) + 1


@boost(nogil=True)
def gpos2(n: int) -> int:
    """Return the value of position n of the Golomb sequence (recursive function)."""
    val: int
    somedict: dict

    val = 1
    if n == val:
        return 1
    return gpos2(n - gpos2(gpos2(n - 1))) + 1


def golomb_sequence(size):
    return [(i, gpos(i)) for i in range(1, size + 1)]


def main(size=None):
    if not size:
        size = 50
    print(golomb_sequence(int(size)))


if __name__ == "__main__":
    import sys

    main(sys.argv[1])
