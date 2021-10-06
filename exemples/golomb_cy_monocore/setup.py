from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize


def pyx_ext_basic(name):
    return Extension(
        name,
        language="c",
        sources=[name + ".pyx"],
        extra_compile_args=[
            "-O3",
            "-Wno-deprecated-declarations",
        ],
    )


extensions = [
    pyx_ext_basic("golomb"),
]

setup(
    ext_modules=cythonize(
        extensions,
        language_level="3str",
    ),
)
