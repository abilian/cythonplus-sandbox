from setuptools import Extension, setup
from Cython.Build import cythonize

extensions = [
    Extension(
        "pthread_barrier",
        language="c",
        sources=["runtime/pthread_barrier.c"],
        extra_compile_args=[
            "-pthread",
            "-Wno-unused-function",
            "-Wno-deprecated-declarations",
        ],
        include_dirs=["/opt/local/include", "runtime"],
        library_dirs=["/opt/local/lib", "runtime"],
        extra_link_args=[],
    ),
    Extension(
        "main",
        language="c++",
        sources=["main.pyx", "runtime/pthread_barrier.c"],
        extra_compile_args=[
            "-pthread",
            "-std=c++11",
            "-march=native",
            "-Wno-unused-function",
            "-Wno-deprecated-declarations",
        ],
        include_dirs=["/opt/local/include", "runtime"],
        library_dirs=[".", "/opt/local/lib", "runtime"],
        libraries=["crypto", "fmt"],
        extra_link_args=["-L. -lpthread_barrier"],
    ),
]


setup(
    name="main_truc",
    ext_modules=cythonize(
        extensions, language_level="3str", include_path=[".", "runtime"]
    ),
)
