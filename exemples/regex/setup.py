from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize


def pyx_ext_basic(name):
    return Extension(
        name,
        language="c++",
        sources=[name + ".pyx"],
        extra_compile_args=[
            "-std=c++17",
            "-O3",
            "-Wno-deprecated-declarations",
        ],
        libraries=["fmt"],
        include_dirs=["libfmt", "stdlib"],
        library_dirs=["libfmt"],
    )


extensions = [
    pyx_ext_basic("test_regex"),
]

setup(
    ext_modules=cythonize(
        extensions,
        language_level="3str",
    ),
)
