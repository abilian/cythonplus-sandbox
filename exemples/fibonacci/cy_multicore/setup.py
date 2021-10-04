from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize


def pyx_ext_multicore(name):
    return Extension(
        name,
        language="c",
        sources=[name + ".pyx"],
        # gcc only:
        extra_compile_args=["-O3", "-Wno-deprecated-declarations", "-fopenmp"],
        extra_link_args=["-fopenmp"],
    )


extensions = [
    pyx_ext_multicore("fibonacci_cy_multicore"),
]

setup(
    ext_modules=cythonize(
        extensions,
        language_level="3str",
    ),
)
