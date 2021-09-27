from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

from extension_any_scalar import ext_any_scalar
from extension_any_scalar_dict import ext_any_scalar_dict
from extension_any_scalar_list import ext_any_scalar_list
from extension_scalar_dicts import ext_scalar_dicts

# compile only libs
setup(
    ext_modules=cythonize(
        [
            ext_any_scalar,
            ext_any_scalar_dict,
            ext_any_scalar_list,
            ext_scalar_dicts,
        ],
        language_level="3str",
    ),
)
