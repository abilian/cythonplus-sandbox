from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

from extension_any_scalar import ext_any_scalar
from extension_any_scalar_dict import ext_any_scalar_dict
from extension_any_scalar_list import ext_any_scalar_list
from extension_scalar_dicts import ext_scalar_dicts

name = "test_containers"


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
            ext_any_scalar,
            ext_any_scalar_dict,
            ext_any_scalar_list,
            ext_scalar_dicts,
        ],
        language_level="3str",
    ),
)
