from distutils.extension import Extension

ext_version = Extension(
    "containerlib.version",
    language="c++",
    sources=["containerlib/version.pyx"],
    extra_compile_args=[
        "-std=c++11",
        "-O3",
        "-Wno-deprecated-declarations",
    ],
    libraries=["fmt"],
    include_dirs=["containerlib"],
)
