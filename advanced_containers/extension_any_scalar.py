from distutils.extension import Extension

ext_any_scalar = Extension(
    "containerlib.any_scalar",
    language="c++",
    sources=["containerlib/any_scalar.pyx"],
    extra_compile_args=[
        "-std=c++11",
        "-O3",
        "-Wno-deprecated-declarations",
    ],
    libraries=["fmt"],
    include_dirs=["containerlib"],
)
