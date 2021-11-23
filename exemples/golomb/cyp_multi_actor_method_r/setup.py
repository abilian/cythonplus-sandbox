from setuptools import Extension, setup
from Cython.Build import cythonize
import platform

if platform.system() == "Darwin":
    pthread_barrier = Extension(
        "pthread_darwin.pthread_barrier",
        language="c",
        sources=["pthread_darwin/pthread_barrier.c"],
        extra_compile_args=[
            "-pthread",
            "-Wno-unused-function",
            "-Wno-deprecated-declarations",
        ],
        include_dirs=[".", "/opt/local/include", "pthread_darwin"],
        library_dirs=[".", "/opt/local/lib", "pthread_darwin"],
        extra_link_args=[],
    )
    golomb = Extension(
        "golomb",
        language="c++",
        sources=["golomb.pyx"],
        extra_compile_args=[
            "-pthread",
            "-std=c++11",
            # "-O3",
            "-march=native",
            "-Wno-unused-function",
            "-Wno-deprecated-declarations",
        ],
        include_dirs=[".", "/opt/local/include", "pthread_darwin", "scheduler_darwin"],
        library_dirs=[".", "/opt/local/lib", "./pthread_darwin", "./scheduler_darwin"],
        # library_dirs=[".", "/opt/local/lib", "runtime"],
        # extra_link_args=["-L.", "-lpthread_barrier"],
        libraries=["pthread_barrier"],
    )
    extensions = [pthread_barrier, golomb]
else:
    golomb = Extension(
        "golomb",
        language="c++",
        sources=["golomb.pyx"],
        extra_compile_args=[
            "-std=c++11",
            "-O3",
            "-Wno-unused-function",
            "-Wno-deprecated-declarations",
            "-pthread",
        ],
    )
    extensions = [golomb]

setup(
    name="golomb",
    ext_modules=cythonize(
        extensions,
        language_level="3str",
        include_path=[".", "pthread_darwin", "scheduler_darwin"],
    ),
)
