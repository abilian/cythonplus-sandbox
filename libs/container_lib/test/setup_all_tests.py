#!/usr/bin/env python
# detect and compile all test_*.pyx files in local folder
from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

from extension_any_scalar import ext_any_scalar
from extension_any_scalar_dict import ext_any_scalar_dict
from extension_any_scalar_list import ext_any_scalar_list
from extension_scalar_dicts import ext_scalar_dicts

from glob import glob
import os
from os import unlink
from os.path import exists, isfile, relpath, splitext


def find_test_pyx():
    found = []
    filenames = glob("*.pyx")
    for name in filenames:
        if not exists(name):
            continue
        if isfile(name) and name.startswith("test_"):
            found.append(relpath(name))
    if not found:
        raise ValueError("No .pyx file found. Exiting.")
    return found


targets = []
for pyx in find_test_pyx():
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

extensions = [
    ext_any_scalar,
    ext_any_scalar_dict,
    ext_any_scalar_list,
    ext_scalar_dicts,
]

for name, pyx in targets:
    extensions.append(
        Extension(
            name,
            [pyx],
            language="c++",
            extra_compile_args=[
                "-std=c++11",
                "-O3",
                "-Wno-deprecated-declarations",
            ],
            libraries=["fmt"],
            include_dirs=["stdlib", "containerlib"],
        )
    )

setup(
    ext_modules=cythonize(
        extensions,
        language_level="3str",
    ),
)
