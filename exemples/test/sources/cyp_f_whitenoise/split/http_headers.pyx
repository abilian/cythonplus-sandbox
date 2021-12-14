# distutils: language = c++
"""https headers, managed like flask Headers
"""
from libcythonplus.dict cimport cypdict
from libcythonplus.list cimport cyplist
from stdlib.string cimport Str
from stdlib._string cimport string
from stdlib.format cimport format
from .stdlib.strip cimport stripped


cdef HttpHeaders make_header(Str key, Str value) nogil:
    cdef HttpHeaders headers

    headers = HttpHeaders()
    headers.set_header(key, value)
    return headers


cdef cypdict[string, string] py_environ_headers(environ):
    cdef cypdict[string, string] headers

    headers = cypdict[string, string]()
    for k, v in environ.items():
        if isinstance(v, str):
            sv = string(bytes(v.encode("utf8")))
        elif isinstance(v, bytes):
            sv = string(bytes(v))
        else:
            continue  # some other object instance
        if isinstance(k, str):
            sk = string(bytes(k.encode("utf8")))
        else:
            sk = string(bytes(k))
        headers[sk] = sv
    return headers
