import ast
import os
from os.path import join
import re
import sys

from setuptools import find_packages

from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

NAME = "server"
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
    src = join(*pathname) + ".py"
    if not os.path.exists(src):
        src += "x"
    if not os.path.exists(src):
        raise ValueError(f"file not found: {src}")
    return Extension(
        ".".join(pathname),
        sources=[src],
        language="c++",
        extra_compile_args=[
            "-pthread",
            "-std=c++17",
            "-O3",
            "-Wno-unused-function",
            "-Wno-deprecated-declarations",
        ],
        libraries=["fmt"],
        include_dirs=["libfmt"],
        library_dirs=["libfmt"],
    )


extensions = [
    pypyx_ext(NAME, "stdlib", "startswith"),
    pypyx_ext(NAME, "stdlib", "abspath"),
    pypyx_ext(NAME, "stdlib", "regex"),
    pypyx_ext(NAME, "stdlib", "strip"),
    pypyx_ext(NAME, "stdlib", "formatdate"),
    pypyx_ext(NAME, "stdlib", "parsedate"),
    pypyx_ext(NAME, "common"),
    pypyx_ext(NAME, "static_file"),
    pypyx_ext(NAME, "scan"),
    pypyx_ext(NAME, "response"),
    pypyx_ext(NAME, "media_types"),
    pypyx_ext(NAME, "http_status"),
    pypyx_ext(NAME, "http_headers"),
    pypyx_ext(NAME, "actor_file_server"),
    pypyx_ext(NAME, "daemon"),
    pypyx_ext(NAME, "server"),
]


setup(
    ext_modules=cythonize(
        extensions,
        language_level="3str",
        include_path=[
            # "stdlib",
            # "server/stdlib",
            # "server",
            os.path.join(PROJECT_ROOT, NAME, "stdlib"),
            os.path.join(PROJECT_ROOT, NAME),
        ],
    ),
    name=NAME,
    version=version,
    author="Jerome Dumonteil",
    author_email="jd@abilian.com",
    url="https://abilian.com",
    packages=find_packages(exclude=["tests*"]),
    license="In progress",
    description="Simple http server, based on Nexedi's cython plus sources.",
    long_description="Simple http server, based on Nexedi's cython plus sources.",
    # classifiers=[
    #     "Development Status :: 5 - Production/Stable",
    #     "Topic :: Internet :: WWW/HTTP :: WSGI :: Middleware",
    #     "Intended Audience :: Developers",
    #     "License :: OSI Approved :: MIT License",
    #     "Operating System :: OS Independent",
    #     "Programming Language :: Python :: 3",
    #     "Programming Language :: Python :: 3.5",
    #     "Programming Language :: Python :: 3.6",
    #     "Programming Language :: Python :: 3.7",
    #     "Programming Language :: Python :: 3.8",
    #     "Programming Language :: Python :: Implementation :: CPython",
    #     "Programming Language :: Python :: Implementation :: PyPy",
    # ],
    python_requires=">=3.5, <4",
    include_package_data=True,
    zip_safe=False,
)
