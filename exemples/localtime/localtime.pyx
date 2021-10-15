# distutils: language = c++
from libc.time cimport ctime, time, time_t, tm, localtime, gmtime
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf


cdef string now_local() nogil:
    cdef time_t t = time(NULL)
    cdef tm* tms
    cdef string result

    tms = localtime(&t)
    result = string(sprintf("%d-%02d-%02dT%02d:%02d:%02d",
                    tms.tm_year + 1900,
                    tms.tm_mon + 1,
                    tms.tm_mday,
                    tms.tm_hour,
                    tms.tm_min,
                    tms.tm_sec
                    ))
    return result


cdef string now_utc() nogil:
    cdef time_t t = time(NULL)
    cdef tm* tms
    cdef string result

    tms = gmtime(&t)
    # result =  string(sprintf("now: %d-%02d-%02d %02d:%02d:%02d", 1, 2, 3, 4, 5, 6))
    result = string(sprintf("%d-%02d-%02dT%02d:%02d:%02d",
                    tms.tm_year + 1900,
                    tms.tm_mon + 1,
                    tms.tm_mday,
                    tms.tm_hour,
                    tms.tm_min,
                    tms.tm_sec
                    ))
    return result


cpdef py_now_utc():
    return now_utc().decode("utf8")


cpdef py_now_local():
    return now_local().decode("utf8")
