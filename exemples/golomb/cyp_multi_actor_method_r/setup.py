from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize
import platform

from distutils import sysconfig

if platform.system() == "Darwin":
    print("Darwin build.")
    vars = sysconfig.get_config_vars()
    vars["LDSHARED"] = vars["LDSHARED"].replace("-bundle", "-dynamiclib")
    golomb = Extension(
        "golomb",
        language="c++",
        sources=["golomb.pyx", "scheduler_darwin/c_pthread_barrier.cxx"],
        extra_compile_args=[
            "-pthread",
            "-std=c++11",
            "-O3",
            "-Wno-unused-function",
            "-Wno-deprecated-declarations",
        ],
        include_dirs=[
            ".",
            "/opt/local/include",
            "scheduler_darwin",
        ],
        library_dirs=[
            ".",
            "/opt/local/lib",
            "scheduler_darwin",
        ],
    )
    setup(
        name="golomb",
        ext_modules=cythonize(
            [golomb],
            language_level="3str",
            include_path=[".", "scheduler_darwin"],
        ),
    )

else:
    print("Linux build.")
    golomb = Extension(
        "golomb",
        language="c++",
        sources=["golomb.pyx"],
        extra_compile_args=[
            "-pthread",
            "-std=c++11",
            "-O3",
            "-Wno-unused-function",
            "-Wno-deprecated-declarations",
        ],
    )
    extensions = [golomb]

    setup(
        name="golomb",
        ext_modules=cythonize(
            [golomb],
            language_level="3str",
            include_path=[".", "pthread", "scheduler"],
        ),
    )
