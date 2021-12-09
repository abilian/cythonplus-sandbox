# distutils: language = c++
import os
from os.path import isdir, abspath, sep, join, commonprefix, isfile, exists
from posixpath import normpath
import re
import warnings
from wsgiref.headers import Headers
from wsgiref.util import FileWrapper

from libcythonplus.dict cimport cypdict
from stdlib._string cimport string
from stdlib.string cimport Str
from stdlib.format cimport format

from .common cimport StrList, Sdict, getdefault
from .header_list cimport HeaderList
from .abspath cimport abspath
from .startswith cimport startswith, endswith
from .scan cimport Finfo, Fdict, scan_fs_dic, from_str, to_str, py_to_string, string_to_py
from .media_types cimport MediaTypes
from .responders cimport make_static_file
from .responders cimport StaticFile, Response
# from .responders import MissingFileError, IsDirectoryError, Redirect, StaticFile
# from .responders import StaticFile

# from .string_utils import decode_if_byte_string, ensure_leading_trailing_slash
    # decode_path_info,

#
#                     prepare a nogil version
#
# cdef class WrapMediaTypes():
#     cdef MediaTypes mt[1]
#
#     def __init__(self, mimetypes):
#         cdef Sdict c_mt
#
#         if mimetypes:
#             c_mt = to_str_dict(mimetypes)
#         else:
#             c_mt = Sdict()
#         self.mt[0] = MediaTypes(c_mt)
#
#     def get_type(self, path):
#         return from_str(self.mt[0].get_type(to_str(path)))

ctypedef cypdict[Str, StaticFile] StaticFileCache


cdef cypclass WhiteNoise:
    Fdict stat_cache
    int max_age
    bint allow_all_origins
    Str charset
    Sdict mimetypes
    Str add_headers_function
    Str application  # FIXME later
    Str root  # FIXME later
    Str prefix  # FIXME later
    MediaTypes media_types
    StaticFileCache files

    __init__(self, Str application, Str root, Str prefix):
        self.stat_cache = NULL
        self.max_age = 60
        self.allow_all_origins = True
        self.charset = Str("utf-8")
        self.mimetypes = NULL  # always NuLL for his implementation
        self.add_headers_function = NULL

        self.application = application
        self.root = root
        self.prefix = prefix

        # self.media_types = WrapMediaTypes(self.mimetypes)
        self.media_types = MediaTypes(self.mimetypes)
        self.files = StaticFileCache()
        # no index_file
        self.add_files()

    # def __call__(self, environ, start_response):
    Str call(self, Sdict environ, Str start_response):  # FIXME later, return Str list ?
        # fixme for start_response, a callback ?
        cdef Str path
        cdef StaticFile static_file
        cdef Response response  # fixme a str list ?

        if Str("PATH_INFO") in environ:
            path = environ[""]
        path = getdefault(environ, Str("PATH_INFO"), Str(""))
        # no autorefresh
        static_file = getdefault(self.files, path, NULL)
        if static_file == NULL:
            # return self.application(environ, start_response)
            return Str("404")  # fixme
        response = static_file.get_response(environ["REQUEST_METHOD"], environ)
        # return response
        return response.status_line()

        #  status_line = f"{response.status} {response.status.phrase}"
        #  start_response(status_line, list(response.headers))
        #  if response.file is None:
           # return []
        #  file_wrapper = environ.get("wsgi.file_wrapper", FileWrapper)
        #  return file_wrapper(response.file)

    void add_files(self):
        cdef Str url
        if self.root == NULL or self.root.__len__() == 0:
            return
        self.root = abspath(self.root)
        if self.root.__len__() == 0:
            return

        while startswith(self.prefix, Str("/")):
            self.prefix = self.prefix.substr(1)
        while endsswith(self.prefix, Str("/")):
            self.prefix = self.prefix.substr(-1)
        if self.prefix.__len__() == 0:
            self.prefix = Str("/")
        else:
            self.prefix = Str("/") + self.prefix + Str("/")

        # Build a mapping from paths to the results of `os.stat` calls
        # so we only have to touch the filesystem once
        # cdef string s_path
        self.stat_cache = scan_fs_dic(self.root)

        for path in self.stat_cache.keys():
            if self.is_compressed_variant_cache(path):
                continue
            relative_path = path.substr(root.__len__()]
            # relative_url = relative_path.replace("\\", "/")
            # url = prefix + relative_url
            url = prefix + relative_path
            self.files[url] = self.get_static_file_cache(path, url)

    bint is_compressed_variant_cache(self, Str path):
        cdef Str uncompressed_path

        if endswith(path, Str(".gz")) or endswith(path, Str(".br")):
            uncompressed_path = path.substr(0,-3)
            if uncompressed_path in self.stat_cache:
                return True
            return False
            # return py_to_string(uncompressed_path) in self.stat_cache_key_set(self)
            # return WNCache.stat_cache_known_key(self, py_to_string(uncompressed_path))
        return False

    StaticFile get_static_file_cache(self, Str path, Str url):
        cdef HeaderList headers

        headers = HeaderList()
        self.add_mime_headers(headers, path, url)
        self.add_cache_headers(headers, path, url)
        if self.allow_all_origins:
            headers.add_header(Str("Access-Control-Allow-Origin"), Str("*"))
        if self.add_headers_function:
            self.add_headers_function(headers, path, url)
        return make_static_file(path, headers_list, self.stat_cache)

    void add_mime_headers(self, HeaderList headers, Str path, Str url):
        ## error: cyp_a_whitenoise/base.pyx:235:37:
        ## Object of type 'MediaTypes' has no attribute 'get_type'
        ## BUG: it does.
        # media_type = self.media_types.get_type(path)
        # media_type = c_wrap_get_type(self.media_types, path)
        media_type = self.media_types.get_type(path)
        if media_type.startswith(Str("text/")):
            headers.add_header_charset(Str("Content-Type"), media_type, self.charset)
        else:
            headers.add_header(Str("Content-Type"), media_type)

    void add_cache_headers(self, HeaderList headers, Str path, Str url):
        if self.max_age > 0 :
            headers.add_header(Str("Cache-Control"),
                               format("max-age={}, public",self.max_age))



    # list stat_cache_keys(self):
    #     return list(s.c_str().decode("utf8", 'replace') for s in self.stat_cache.keys())

    # bint stat_cache_known_key(self, Str key):
    #     return key in self.stat_cache
