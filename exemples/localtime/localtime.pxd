# distutils: language = c++
from libc.time cimport ctime, time, time_t, tm, localtime
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf


cdef string now_local() nogil
cdef string now_utc() nogil
