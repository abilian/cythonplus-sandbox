from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize


def pyx_ext(name):
    return Extension(
        name,
        language="c++",
        sources=[name + ".pyx"],
        extra_compile_args=[
            "-std=c++17",
            "-O3",
            "-Wno-deprecated-declarations",
        ],
        include_dirs=["stdlib"],
    )


extensions = [
    pyx_ext("startswith"),
    pyx_ext("test_startswith"),
]

setup(
    ext_modules=cythonize(
        extensions,
        language_level="3str",
    ),
)
