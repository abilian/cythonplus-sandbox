from stdlib.string cimport Str

cdef extern from "<fmt/printf.h>" namespace "fmt" nogil:

    ctypedef struct FILE

    int printf       (const char* template, ...)
    int printf       (Str template, ...)
    int fprintf      (FILE *stream, const char* template, ...)
    Str sprintf      (const char* template, ...)
    Str sprintf      (Str template, ...)
