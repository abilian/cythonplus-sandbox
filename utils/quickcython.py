#!/usr/bin/env python
# Quick way to compile pyx files for cython+, maybe finding defaults for
# any cyp+ source. WIP.
# license: MIT
# usage: quickcython [xxx.pyx], if no args, default to *.pyx
# Most brilliant ideas of this script coming from https://github.com/cjrh/easycython

import os
import sys
from distutils.core import setup
from distutils.extension import Extension
from glob import glob
from os import unlink
from os.path import exists, isdir, isfile, join, relpath, splitext

from Cython.Build import cythonize
from Cython.Distutils import build_ext

# for testing purpose, several compile args choices:
extra1 = ["-pthread", "-std=c++11"]
extra2 = (["-O3", "-ffast-math", "-march=native", "-fopenmp"],)
extra3 = [
    "-g0",
    "-O3",
    "-Wno-unused-function",
    "-Wno-unreachable-code",
    "-Wno-deprecated-declarations",
]
extra4 = [
    "-pthread",
    "-std=c++11",
    "-O3",
    "-march=native",
    "-Wno-unused-function",
    "-Wno-deprecated-declarations",
]

extra_compile = extra4

libs = ["fmt", "ssl"]
links = []
includes = []
# includes = [numpy.get_include()]
# libs = ["m"]
# links = ["-fopenmp"]


def normalize_args(filenames):
    found = []
    if not filenames:
        filenames = glob("*.pyx")
    for name in filenames:
        if not exists(name):
            continue
        if isfile(name):
            found.append(relpath(name))
        if isdir(name):
            found.extend([relpath(f) for f in glob(join(name, "*.pyx"))])
    if not found:
        raise ValueError("No .pyx file found. Exiting.")
    return found


def make(filenames):
    targets = []
    print("-" * 40)
    for pyx in normalize_args(filenames):
        base = splitext(pyx)[0]
        dot_name = base.replace(os.sep, ".")
        while dot_name.startswith("."):
            dot_name = dot_name[1:]
        targets.append((dot_name, pyx))
        print(dot_name, "added")
        cpp = base + ".cpp"
        if exists(cpp):
            unlink(cpp)
            print(cpp, "cleaned")
    print("-" * 40)

    extensions = []
    for name, pyx in targets:
        extensions.append(
            Extension(
                name,
                [pyx],
                libraries=libs,
                extra_compile_args=extra_compile,
                extra_link_args=links,
            )
        )

    print(extensions)

    # hack !
    sys.argv = [sys.argv[0], "build_ext", "--inplace"]

    setup(
        cmdclass={"build_ext": build_ext},
        include_dirs=includes,
        ext_modules=cythonize(
            extensions,
            language_level="3str",
        ),
    )


if __name__ == "__main__":
    make(sys.argv[1:])
