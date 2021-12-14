# distutils: language = c++
import os
from os.path import isdir, sep, join, commonprefix, isfile, exists
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
from .startswith cimport startswith, endswith
from .abspath cimport abspath
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

# remove options:
# autorefresh
# index_file
# immutable_file_test




#
# cdef class WNCache:
#     cdef Fdict stat_cache
#
#     cdef void scan_tree(self, root):
#         self.stat_cache = scan_fs_dic(to_str(root))
#
#     cdef c_make_static_file(self, str path, list headers_list):
#         return make_static_file(path, headers_list, self.stat_cache)
#
#     cdef list stat_cache_keys(self):
#         return list(s.c_str().decode("utf8", 'replace') for s in self.stat_cache.keys())
#
#     cdef bint stat_cache_known_key(self, string key):
#         return key in self.stat_cache
#

#
#
# # cdef class WhiteNoise():
# class WhiteNoise(WNCache):
#     ## we need a cdef to ba able of manage a MediaTypes attribute...
#     ## => no **kwargs in __ini__
#     ## => will need some wrapper to keep API, TODO
#     ## For now : no optional args
#     # cdef MediaTypes media_types
#
#     # Ten years is what nginx sets a max age if you use 'expires max;'
#     # so we'll follow its lead
#     # FOREVER = 10 * 365 * 24 * 60 * 60
#
#     # # Attributes that can be set by keyword args in the constructor
#     # config_attrs = (
#     #     "autorefresh",
#     #     "max_age",
#     #     "allow_all_origins",
#     #     "charset",
#     #     "mimetypes",
#     #     "add_headers_function",
#     #     "index_file",
#     #     "immutable_file_test",
#     # )
#
#     # Re-check the filesystem on every request so that any changes are
#     # automatically picked up. NOTE: For use in development only, not supported
#     # in production
#     # autorefresh = False
#
#     ## BUG AttributeError: 'cyp_a_whitenoise.base.WhiteNoise' object attribute 'max_age' is read-only
#     ## => cant be so "dynamic"
#     ## => make all class attribute instance attributes
#     ## max_age = 60
#     max_age = 60
#
#     # Set 'Access-Control-Allow-Orign: *' header on all files.
#     # As these are all public static files this is safe (See
#     # https://www.w3.org/TR/cors/#security) and ensures that things (e.g
#     # webfonts in Firefox) still work as expected when your static files are
#     # served from a CDN, rather than your primary domain.
#     allow_all_origins = True
#     charset = "utf-8"
#     # Custom mime types
#     mimetypes = None
#     # Callback for adding custom logic when setting headers
#     add_headers_function = None
#     # Name of index file (None to disable index support)
#     # index_file = None
#
#     def __init__(self, application, root=None, prefix=None, max_age=60):
#         self.media_types = WrapMediaTypes(self.mimetypes)
#         self.application = application
#         self.files = {}
#         # self.directories = []
#         # no index_file
#         if root is not None:
#             self.add_files(root, prefix)
#
#     def __call__(self, environ, start_response):
#         path = environ.get("PATH_INFO", "")
#         # no autorefresh
#         static_file = self.files.get(path)
#         if static_file is None:
#             return self.application(environ, start_response)
#         response = static_file.get_response(environ["REQUEST_METHOD"], environ)
#         status_line = f"{response.status} {response.status.phrase}"
#         start_response(status_line, list(response.headers))
#         if response.file is None:
#             return []
#         file_wrapper = environ.get("wsgi.file_wrapper", FileWrapper)
#         return file_wrapper(response.file)
#
#     def add_files(self, root, prefix=None):
#         root = decode_if_byte_string(root, force_text=True)
#         root = abspath(root)
#         root = root.rstrip(sep) + sep
#         prefix = decode_if_byte_string(prefix)
#         prefix = ensure_leading_trailing_slash(prefix)
#         if isdir(root):
#             self.update_files_dictionary(root, prefix)
#         else:
#             warnings.warn(f"No directory at: {root}")
#
#     def update_files_dictionary(self, root, prefix):
#         # Build a mapping from paths to the results of `os.stat` calls
#         # so we only have to touch the filesystem once
#         # cdef string s_path
#
#         WNCache.scan_tree(self, root)
#         for path in WNCache.stat_cache_keys(self):
#             if self.is_compressed_variant_cache(path):
#                 continue
#             relative_path = path[len(root):]
#             relative_url = relative_path.replace("\\", "/")
#             url = prefix + relative_url
#             self.files[url] = self.get_static_file_cache(path, url)
#
#     def is_compressed_variant_cache(self, path):
#         if path[-3:] in (".gz", ".br"):
#             uncompressed_path = path[:-3]
#             # return py_to_string(uncompressed_path) in self.stat_cache_key_set(self)
#             return WNCache.stat_cache_known_key(self, py_to_string(uncompressed_path))
#         return False
#
#     def get_static_file_cache(self, path, url):
#         headers = Headers([])
#         self.add_mime_headers(headers, path, url)
#         self.add_cache_headers(headers, path, url)
#         if self.allow_all_origins:
#             headers["Access-Control-Allow-Origin"] = "*"
#         if self.add_headers_function:
#             self.add_headers_function(headers, path, url)
#         return WNCache.c_make_static_file(self, path, headers.items())
#
#     def add_mime_headers(self, headers, path, url):
#         ## error: cyp_a_whitenoise/base.pyx:235:37:
#         ## Object of type 'MediaTypes' has no attribute 'get_type'
#         ## BUG: it does.
#         # media_type = self.media_types.get_type(path)
#         # media_type = c_wrap_get_type(self.media_types, path)
#         media_type = self.media_types.get_type(path)
#         if media_type.startswith(Str("text/")):
#             headers.add_header_charset(Str("Content-Type"), media_type, self.charset)
#         else:
#             headers.add_header(Str("Content-Type"), media_type)
#
#     def add_cache_headers(self, headers, path, url):
#         if self.max_age is not None:
#             headers["Cache-Control"] = f"max-age={self.max_age}, public"
#

cdef const char* to_c_str(byte_or_string):
    """(need gil)
    """
    if isinstance(byte_or_string, str):
        return bytes(byte_or_string.encode("utf8"))
    else:
        return bytes(byte_or_string)


cdef Sdict to_str_dict(python_dict):
    """create a Sdict instance from a str/str python dict

    (need gil)
    """
    sd = Sdict()
    for key, value in python_dict.items():
        sd[Str(key)] = Str(value)
    return sd


cdef dict from_str_dict(Sdict sd):
    """create a python dict instance from a Sdict

    (need gil)
    """
    return {
        from_str(i.first): from_str(i.second) for i in sd.items()
    }


cdef class WrapMediaTypes():
    cdef MediaTypes mt[1]

    def __init__(self, mimetypes):
        cdef Sdict c_mt

        if mimetypes:
            c_mt = to_str_dict(mimetypes)
        else:
            c_mt = Sdict()
        self.mt[0] = MediaTypes(c_mt)

    def get_type(self, path):
        return from_str(self.mt[0].get_type(to_str(path)))
