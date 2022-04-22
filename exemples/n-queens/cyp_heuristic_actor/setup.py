from setuptools import setup
from setuptools.extension import Extension
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
            "-pthread",
        ],
    )


extensions = [
    pyx_ext("n_queens_adv_heuristic_actor"),
]

setup(
    ext_modules=cythonize(
        extensions,
        language_level="3str",
    ),
)
