from distutils.extension import Extension

ext_any_scalar_list = Extension(
    "containerlib.any_scalar_list",
    language="c++",
    sources=["containerlib/any_scalar_list.pyx"],
    extra_compile_args=[
        "-std=c++11",
        "-O3",
        "-Wno-deprecated-declarations",
    ],
    libraries=["fmt"],
    include_dirs=["containerlib"],
)
