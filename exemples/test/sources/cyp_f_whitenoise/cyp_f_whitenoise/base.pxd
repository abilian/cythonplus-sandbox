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
from .common_types cimport StrList, StrPair, HeaderList, Sdict, getdefault
from .scan cimport Finfo, Fdict, scan_fs_dic, from_str, to_str, py_to_string, string_to_py

from .media_types cimport MediaTypes

from .responders cimport make_static_file
from .responders cimport StaticFile, Response
# from .responders import MissingFileError, IsDirectoryError, Redirect, StaticFile
# from .responders import StaticFile

from .string_utils import decode_if_byte_string, ensure_leading_trailing_slash
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

        d if root == NULL or root.__len__ == 0:
            return

        root = decode_if_byte_string(root, force_text=True)
        root = abspath(root)
        root = root.rstrip(sep) + sep
        prefix = decode_if_byte_string(prefix)
        prefix = ensure_leading_trailing_slash(prefix)
        if isdir(root):
            self.update_files_dictionary(root, prefix)
        else:
            warnings.warn(f"No directory at: {root}")


    void scan_tree(self):
        self.stat_cache = scan_fs_dic(self.root)

    StaticFile c_make_static_file(self, Str path, HeaderList headers_list):
        return make_static_file(path, headers_list, self.stat_cache)

    # list stat_cache_keys(self):
    #     return list(s.c_str().decode("utf8", 'replace') for s in self.stat_cache.keys())

    # bint stat_cache_known_key(self, Str key):
    #     return key in self.stat_cache
