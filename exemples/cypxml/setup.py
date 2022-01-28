import ast
import os
from os.path import join
import re
import sys

from setuptools import find_packages

from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

NAME = "cypxml"
PROJECT_ROOT = os.path.abspath(os.path.dirname(__file__))


def read(*path):
    full_path = join(PROJECT_ROOT, *path)
    with open(full_path, "r", encoding="utf-8") as f:
        return f.read()


def read_version():
    version_re = re.compile(r"__version__\s+=\s+(.*)")
    version_string = version_re.search(read(join(NAME, "__init__.py"))).group(1)
    return str(ast.literal_eval(version_string))


version = read_version()


def pypyx_ext(*pathname):
    src = join(*pathname) + ".pyx"
    if not os.path.exists(src):
        src = join(*pathname) + ".py"
    if not os.path.exists(src):
        raise ValueError(f"file not found: {src}")
    return Extension(
        ".".join(pathname),
        sources=[src],
        language="c++",
        extra_compile_args=[
            # "-pthread",
            "-std=c++17",
            # "-std=c++11",
            "-O3",
            "-Wno-unused-function",
            "-Wno-deprecated-declarations",
        ],
        libraries=["fmt"],
        include_dirs=["libfmt"],
        library_dirs=["libfmt"],
    )


extensions = [
    pypyx_ext(NAME, "stdlib", "xml_utils"),
    pypyx_ext(NAME, "test_xml_utils"),
    pypyx_ext(NAME, "cypxml"),
    pypyx_ext(NAME, "test_cypxml"),
    pypyx_ext(NAME, "test_perf"),
    pypyx_ext(NAME, "__init__"),
]


setup(
    ext_modules=cythonize(
        extensions,
        language_level="3str",
        include_path=[
            os.path.join(PROJECT_ROOT, NAME, "stdlib"),
            os.path.join(PROJECT_ROOT, NAME),
        ],
    ),
    name=NAME,
    version=version,
    author="Jerome Dumonteil",
    author_email="jd@abilian.com",
    url="https://github.com/abilian/cythonplus-sandbox/exemples/xmlcyp",
    packages=find_packages(exclude=["tests*"]),
    license="MIT",
    description="Some lib using Cython+",
    long_description="Some lib using Cython+",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Topic :: Internet",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Operating System :: POSIX :: Linux",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: Implementation :: CythonPlus",
    ],
    python_requires=">=3.8, <4",
    include_package_data=True,
    zip_safe=False,
)
