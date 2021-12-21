# distutils: language = c++
import os
from posixpath import normpath
import re
import sys
import warnings
from wsgiref.headers import Headers
from wsgiref.util import FileWrapper

from libc.stdio cimport printf, puts
from stdlib.string cimport Str
from stdlib._string cimport string
from stdlib.format cimport format
from libcythonplus.dict cimport cypdict

from .stdlib.abspath cimport abspath
from .stdlib.startswith cimport startswith, endswith
from .stdlib.strip cimport stripped
from .stdlib.regex cimport re_is_match

from .common cimport Sdict, getdefault, StrList, Finfo, Fdict
from .http_status cimport get_status_line
from .http_headers cimport HttpHeaders, py_environ_headers
from .media_types cimport MediaTypes
from .scan cimport scan_fs_dic
from .static_file cimport StaticFile
from .response cimport Response


cdef class XNoise:
    cdef Noise noise

    def __init__(self):
        self.noise = Noise()

    cdef void start(self, Str root, Str prefix):
        with nogil:
            self.noise.start(root, prefix)

    cdef int nb_cached_files(self):
        with nogil:
            return self.noise.files.__len__()

    cdef Response call(self, Sdict environ_headers):
        with nogil:
            return self.noise.call(environ_headers)


# cdef class WhiteNoise():
class WhiteNoise(XNoise):
    # FOREVER = 10 * 365 * 24 * 60 * 60
    # autorefresh = False
    # max_age = 60
    # allow_all_origins = True
    # charset = "utf-8"
    # mimetypes = None
    # add_headers_function = None
    # index_file = None
    def __init__(self, application, root=None, prefix=None, max_age=None):
        cdef Str croot, cprefix

        self.application = application
        if root:
            croot = to_str(root)
        else:
            croot = NULL
        if prefix is not None:
            cprefix = to_str(prefix)
        else:
            cprefix = NULL

        XNoise.__init__(self)
        XNoise.start(self, croot, cprefix)

    def nb_cached_files(self):
        return XNoise.nb_cached_files(self)

    def __call__(self, environ, start_response):
        cdef Sdict environ_headers
        cdef Response response

        environ_headers = py_environ_headers(environ)
        response = XNoise.call(self, environ_headers)
        if response is NULL:
            # static_file is None:
            return self.application(environ, start_response)
        status_line = response.status_line.decode("utf8", "replace")
        headers = [(
            item.first._str.c_str().decode("utf-8", "replace"),
            item.second._str.c_str().decode("utf-8", "replace"),
            ) for item in environ_headers.items()]  # fixme: order of headers
        start_response(status_line, headers)
        if response.file_path is NULL:
            return []
        path = response.file_path._str.c_str().decode("utf-8", "replace")
        file_wrapper = environ.get("wsgi.file_wrapper", FileWrapper)
        return file_wrapper(open(path, "rb"))


cdef string to_string(byte_or_string):
    if isinstance(byte_or_string, str):
        return string(bytes(byte_or_string.encode("utf8", "replace")))
    else:
        return string(bytes(byte_or_string))


cdef Str to_str(byte_or_string):
    if isinstance(byte_or_string, str):
        return Str(byte_or_string.encode("utf8", "replace"))
    else:
        return Str(bytes(byte_or_string))
