from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

name = "set_exp_string"

setup(
    ext_modules=cythonize(
        [
            Extension(
                name,
                language="c++",
                sources=[name + ".pyx"],
                extra_compile_args=[
                    "-std=c++11",
                    "-O3",
                    "-Wno-deprecated-declarations",
                ],
                libraries=["fmt"],
            ),
        ],
        language_level="3str",
    )
)
