from distutils.extension import Extension

ext_any_scalar_dict = Extension(
    "containerlib.any_scalar_dict",
    language="c++",
    sources=["containerlib/any_scalar_dict.pyx"],
    extra_compile_args=[
        "-std=c++11",
        "-O3",
        "-Wno-deprecated-declarations",
    ],
    libraries=["fmt"],
    include_dirs=["containerlib"],
)
