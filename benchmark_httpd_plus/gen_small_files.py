#!/usr/bin/env python
import sys
from os import makedirs
from os.path import join, exists
from random import Random, randint

WANTED = 50000


def main(dest):
    if exists(dest):
        print("===========================================================")
        print("need to remove manually existing folder:", dest)
        print("===========================================================")
        sys.exit(1)
    makedirs(dest)
    r = Random()
    r.seed(1415)
    for ref in range(1, WANTED + 1):
        length = randint(1000, 7000)
        txt = chr(randint(32, 128)) * length
        fname = f"{ref}.txt"
        path = join(dest, fname)
        with open(path, "w") as f:
            f.write(txt)


if __name__ == "__main__":
    dest = sys.argv[1]
    main(dest)
