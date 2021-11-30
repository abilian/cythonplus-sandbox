from stdlib._string cimport string

cdef extern from "<fmt/printf.h>" namespace "fmt" nogil:

    ctypedef struct FILE

    int printf       (const char* template, ...)
    int printf       (string template, ...)
    int fprintf      (FILE *stream, const char* template, ...)
    string sprintf   (const char* template, ...)
