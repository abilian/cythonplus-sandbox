from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

scan = Extension(
    "scan",
    language="c++",
    sources=["scan.pyx"],
    extra_compile_args=[
        "-pthread",
        "-std=c++17",
        "-O3",
        "-Wno-unused-function",
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
    name="scan",
    ext_modules=cythonize(
        [scan],
        language_level="3str",
        # include_path=[".", "stdlib", "pthread", "scheduler"],
    ),
)
