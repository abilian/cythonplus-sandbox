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


ctypedef cypdict[string, StaticFile] StaticFileCache


cdef cypclass Noise:
    Fdict stat_cache
    int max_age
    bint allow_all_origins
    Str charset
    Sdict mimetypes
    Str add_headers_function
    Str root
    Str prefix
    MediaTypes media_types
    StaticFileCache files

    __init__(self):
        self.stat_cache = NULL
        self.max_age = 60
        self.allow_all_origins = True
        self.charset = Str("utf-8")
        self.mimetypes = NULL  # always NULL for his implementation
        self.add_headers_function = NULL

    void start(self, Str root, Str prefix):
        self.root = root
        self.prefix = prefix
        self.media_types = MediaTypes(self.mimetypes)
        self.files = StaticFileCache()
        self.add_files()

    Response call(self, Sdict environ_headers):
        cdef StaticFile static_file
        cdef Response response
        cdef Str path_info_key = Str("PATH_INFO")
        cdef Str path_info

        if path_info_key not in environ_headers:
            return NULL
        path_info = environ_headers[path_info_key]
        if path_info._str not in self.files:
            return NULL
        static_file = self.files[path_info._str]
        response = static_file.get_response(environ_headers)
        return response

    void add_files(self):
        cdef Str url, path
        cdef string cpath

        if self.root is NULL or self.root.__len__() == 0:
            return
        self.root = abspath(self.root)
        while endswith(self.root, Str("/")):
            self.root = self.root.substr(1)
        if self.root.__len__() == 0:
            return

        while startswith(self.prefix, Str("/")):
            self.prefix = self.prefix.substr(1)
        while endswith(self.prefix, Str("/")):
            self.prefix = self.prefix.substr(0, -1)
        if self.prefix.__len__() == 0:
            self.prefix = Str("/")
        else:
            self.prefix = Str("/") + self.prefix + Str("/")

        # Build a mapping from paths to the results of `os.stat` calls
        # so we only have to touch the filesystem once
        # cdef string s_path
        self.stat_cache = scan_fs_dic(self.root)

        for cpath in self.stat_cache.keys():
            path = new Str()
            path._str = cpath
            if self.is_compressed_variant_cache(path):
                continue
            relative_path = path.substr(root.__len__())
            while startswith(relative_path, Str("/")):
                relative_path = relative_path.substr(1)
            url = prefix + relative_path
            self.files[url._str] = self.get_static_file_cache(path, url)

    bint is_compressed_variant_cache(self, Str path):
        cdef Str uncompressed_path

        if endswith(path, Str(".gz")) or endswith(path, Str(".br")):
            uncompressed_path = path.substr(0, -3)
            if uncompressed_path._str in self.stat_cache:
                return True
            return False
        return False

    StaticFile get_static_file_cache(self, Str path, Str url):
        cdef HttpHeaders headers

        headers = HttpHeaders()
        self.add_mime_headers(headers, path)
        self.add_cache_headers(headers)
        if self.allow_all_origins:
            headers.set_header(Str("Access-Control-Allow-Origin"), Str("*"))
        # FIXME: see later:
        # if self.add_headers_function:
        #     self.add_headers_function(headers, path, url)
        return StaticFile(path, headers, self.stat_cache)

    void add_mime_headers(self, HttpHeaders headers, Str path):
        cdef Str media_type

        media_type = self.media_types.get_type(path)
        if startswith(media_type, Str("text/")):
            headers.set_header_charset(
                            Str("Content-Type"), media_type, self.charset)
        else:
            headers.set_header(Str("Content-Type"), media_type)

    void add_cache_headers(self, HttpHeaders headers):
        if self.max_age > 0:
            age = format("max-age={}, public", self.max_age)
            headers.set_header(Str("Cache-Control"),
                               format("max-age={}, public", self.max_age))


cdef string to_string(byte_or_string)
cdef Str to_str(byte_or_string)
