from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

name = "string_exp"

ext = Extension(
    name,
    language="c++",
    sources=[name + ".pyx"],
    extra_compile_args=[
        "-std=c++17",
        "-O3",
        "-Wno-deprecated-declarations",
    ],
    libraries=["fmt"],
    include_dirs=[
        "libfmt",
    ],
    library_dirs=[
        "libfmt",
    ],
)

setup(
    ext_modules=cythonize(
        [ext],
        language_level="3str",
    )
)
