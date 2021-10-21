from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize


ext_localtime = Extension(
    "localtime",
    language="c++",
    sources=["localtime.pyx"],
    extra_compile_args=[
        "-std=c++11",
        "-O3",
        "-Wno-deprecated-declarations",
    ],
    libraries=["fmt"],
)

ext_show_local_time = Extension(
    "show_local_time",
    language="c++",
    sources=["show_local_time.pyx"],
    extra_compile_args=[
        "-std=c++11",
        "-O3",
        "-Wno-deprecated-declarations",
    ],
    libraries=["fmt"],
)


setup(
    ext_modules=cythonize(
        [ext_localtime, ext_show_local_time],
        language_level="3str",
    )
)
