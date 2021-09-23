from distutils.extension import Extension

ext_scalar_dicts = Extension(
    "containerlib.scalar_dicts",
    language="c++",
    sources=["containerlib/scalar_dicts.pyx"],
    extra_compile_args=[
        "-std=c++11",
        "-O3",
        "-Wno-deprecated-declarations",
    ],
    libraries=["fmt"],
    include_dirs=["containerlib"],
)
