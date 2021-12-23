from libcythonplus.list cimport cyplist
from libcythonplus.dict cimport cypdict
from .stdlib.formatdate cimport formatlog
from stdlib.string cimport Str
from stdlib._string cimport string
from posix.types cimport off_t


cdef Str getdefault(cypdict[Str, Str] d, Str key, Str default) nogil:
    if key in d:
        return d[key]
    return default


cdef void xlog(msg):
    cdef Str now

    now = formatlog()
    with open("/tmp/a.log", "a+") as f:
        f.write(f"{now.bytes().decode('utf-8')} - {str(msg)}\n")
