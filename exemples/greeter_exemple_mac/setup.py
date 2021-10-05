from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize


def pyx_ext(name):
    return Extension(
        name,
        language="c++",
        sources=[name + ".pyx"],
        extra_compile_args=[
            "-std=c++11",
            "-O3",
            "-Wno-deprecated-declarations",
            "-march=native",
            "-pthread",
        ],
        library_dirs=["macthreads"],
        include_dirs=["macthreads"],
        libraries=["pthread_barrier"],
    )


extensions = [
    pyx_ext("test"),
]

setup(
    ext_modules=cythonize(
        extensions,
        language_level="3str",
    ),
)
