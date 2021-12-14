from collections import namedtuple
from email.utils import formatdate, parsedate
import errno

from http import HTTPStatus
import os
import re
import stat
from time import mktime
from urllib.parse import quote

from wsgiref.headers import Headers

from libcythonplus.dict cimport cypdict
from libcythonplus.list cimport cyplist
from stdlib._string cimport string
from stdlib.string cimport Str

from .common cimport StrList, Sdict, getdefault
from .header_list cimport HeaderList
from .common cimport StrList
from .scan cimport Finfo, Fdict, from_str, to_str
from .http_status cimport HttpStatus, HttpStatusDict, generate_http_status_dict


cdef cypclass Alternative:
    Str encoding_pattern
    Str file_path
    HeaderList items

    __init__(self, Str encoding_pattern, Str file_path, HeaderList items):
        self.encoding_pattern = encoding_pattern
        self.file_path = file_path
        self.items = items


ctypedef cyplist[Alternative] AlternativeList


cdef cypclass Response:
    HttpStatus status
    HeaderList headers
    Str file  # will be changed later to file handler

    __init__(self, HttpStatus status, HeaderList headers, Str file):
        self.status = status
        self.headers = headers
        self.file = file

    Str status_line(self):
        return self.status.status_line()


cdef cypclass StaticFile:
    Str path

    __init__(self, Str path, HeaderList headers_list, StrList xxx):
        ## self.stat_cache = stat_cache
        ## encodings = {"gzip": path + ".gz", "br": path + ".br"}
        ## files = self.get_file_stats(path, encodings)
        # headers = self.get_headers(headers_list, files)
        # self.last_modified = parsedate(headers["Last-Modified"])
        # self.etag = headers["ETag"]
        # self.not_modified_response = self.get_not_modified_response(headers)
        # self.alternatives = get_alternatives(headers, files)
        self.path = path  # unused

    Response get_response(self, Str xxx, Sdict sd):
        return Response(HttpStatus(1,Str("OK"),Str("OK")),HeaderList(), Str("fff"))

# cdef AlternativeList get_alternatives(base_headers, files) nogil:
cdef StaticFile make_static_file(Str, HeaderList, Fdict) nogil
# cdef xxx file_stats(Str, Fdict)
cdef HeaderList gen_header_list(Str, Str) nogil
cdef StrList gen_not_modified_headers() nogil
cdef bint re_match(Str, Str) nogil
