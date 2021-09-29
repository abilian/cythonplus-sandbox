from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

from extension_any_scalar import ext_any_scalar
from extension_any_scalar_dict import ext_any_scalar_dict
from extension_any_scalar_list import ext_any_scalar_list
from extension_scalar_dicts import ext_scalar_dicts


def pyx_ext(name):
    return Extension(
        name,
        language="c++",
        sources=[name + ".pyx"],
        extra_compile_args=[
            "-std=c++11",
            "-O3",
            "-Wno-deprecated-declarations",
        ],
        libraries=["fmt"],
    )


extensions = [
    ext_any_scalar,
    ext_any_scalar_dict,
    ext_any_scalar_list,
    ext_scalar_dicts,
    pyx_ext("engine"),
    pyx_ext("localtime"),
]

setup(
    ext_modules=cythonize(
        extensions,
        language_level="3str",
    ),
)
