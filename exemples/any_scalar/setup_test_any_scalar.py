from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

name = "test_any_scalar"

ext_scalar = Extension(
    "stdlib.any_scalar",
    language="c++",
    sources=["stdlib/any_scalar.pyx"],
    extra_compile_args=[
        "-std=c++11",
        "-O3",
        "-Wno-deprecated-declarations",
    ],
    libraries=["fmt"],
    include_dirs=["stdlib"],
)


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
                include_dirs=["stdlib"],
            ),
            ext_scalar,
        ],
        language_level="3str",
    ),
    # package_data={
    #     "any_scalar.any_scalar": ["any_scalar/*.pxd"],
    # },
)
