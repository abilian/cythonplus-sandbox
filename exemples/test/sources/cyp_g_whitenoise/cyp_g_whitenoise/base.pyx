# distutils: language = c++
import os
from posixpath import normpath
import re
import sys
import warnings
from wsgiref.headers import Headers
from wsgiref.util import FileWrapper

from libcythonplus.dict cimport cypdict
from stdlib._string cimport string
from stdlib.string cimport Str
from .scan cimport Finfo, Fdict, scan_fs_dic, from_str, to_str, py_to_string, string_to_py

from .media_types cimport MediaTypes, Sdict#, c_wrap_get_type

from .responders cimport make_static_file
from .responders import MissingFileError, IsDirectoryError, Redirect, StaticFile

from .string_utils import (
    decode_if_byte_string,
    decode_path_info,
    ensure_leading_trailing_slash,
)

# def xlog(*msg):
#     with open("/tmp/a.log", "a+") as f:
#         f.write(" ".join(list(str(x) for x in msg))+"\n")

cdef class WNCache:
    cdef Fdict stat_cache

    cdef void scan_tree(self, root):
        self.stat_cache = scan_fs_dic(to_str(root))

    cdef c_make_static_file(self, str path, list headers_list):
        return make_static_file(path, headers_list, self.stat_cache)

    cdef list stat_cache_keys(self):
        return list(s.c_str().decode("utf8", 'replace') for s in self.stat_cache.keys())

    cdef bint stat_cache_known_key(self, string key):
        return key in self.stat_cache


# cdef class WhiteNoise():
class WhiteNoise(WNCache):
    ## we need a cdef to ba able of manage a MediaTypes attribute...
    ## => no **kwargs in __ini__
    ## => will need some wrapper to keep API, TODO
    ## For now : no optional args
    # cdef MediaTypes media_types

    # Ten years is what nginx sets a max age if you use 'expires max;'
    # so we'll follow its lead
    FOREVER = 10 * 365 * 24 * 60 * 60

    # # Attributes that can be set by keyword args in the constructor
    # config_attrs = (
    #     "autorefresh",
    #     "max_age",
    #     "allow_all_origins",
    #     "charset",
    #     "mimetypes",
    #     "add_headers_function",
    #     "index_file",
    #     "immutable_file_test",
    # )

    # Re-check the filesystem on every request so that any changes are
    # automatically picked up. NOTE: For use in development only, not supported
    # in production
    autorefresh = False

    ## BUG AttributeError: 'cyp_a_whitenoise.base.WhiteNoise' object attribute 'max_age' is read-only
    ## => cant be so "dynamic"
    ## => make all class attribute instance attributes
    ## max_age = 60
    max_age = 60

    # Set 'Access-Control-Allow-Orign: *' header on all files.
    # As these are all public static files this is safe (See
    # https://www.w3.org/TR/cors/#security) and ensures that things (e.g
    # webfonts in Firefox) still work as expected when your static files are
    # served from a CDN, rather than your primary domain.
    allow_all_origins = True
    charset = "utf-8"
    # Custom mime types
    mimetypes = None
    # Callback for adding custom logic when setting headers
    add_headers_function = None
    # Name of index file (None to disable index support)
    index_file = None

    # def __init__(self, application, root=None, prefix=None, **kwargs):
    def __init__(self, application, root=None, prefix=None, max_age=60):
        # xlog("=============================================================")
        # xlog("init of WN")

        # for attr in self.config_attrs:
        #     try:
        #         value = kwargs.pop(attr)
        #     except KeyError:
        #         pass
        #     else:
        #         value = decode_if_byte_string(value)
        #         setattr(self, attr, value)
        # if kwargs:
        #     raise TypeError(
        #         "Unexpected keyword argument '{0}'".format(list(kwargs.keys())[0])
        #     )

        ## wrapping with nogil cypclass
        ## if error cyp_a_whitenoise/base.pyx:74:43: Cannot convert 'cypdict[string,string]' to Python object
        ## => set a pxd declaration

        # self.media_types = make_media_types(self.mimetypes)
        self.media_types = WrapMediaTypes(self.mimetypes)

        self.application = application
        self.files = {}
        self.directories = []
        if self.index_file is True:
            self.index_file = "index.html"
        if not callable(self.immutable_file_test):
            regex = re.compile(self.immutable_file_test)
            self.immutable_file_test = lambda path, url: bool(regex.search(url))
        self.last_ok = {}
        if root is not None:
            # xlog("add files", root)
            self.add_files(root, prefix)
        # self.stat_cache = Fdict()

    def nb_cached_files(self):
        return len(self.files)

    def __call__(self, environ, start_response):
        # with open("/tmp/aaa.txt", "w", encoding="utf8") as f:
        #     for k, v in environ.items():
        #         f.write(f"{k}:{v}\n")
        # sys.exit()
        # path = decode_path_info(environ.get("PATH_INFO", ""))
        path = environ.get("PATH_INFO", "")
        # xlog("--->", path)
        ##last_ok = self.last_ok.get(path)
        # xlog(last_ok)
        # if last_ok and environ["REQUEST_METHOD"] == "GET":
        #     start_response(last_ok[0], last_ok[1])
        #     file_wrapper = environ.get("wsgi.file_wrapper", FileWrapper)
        #     # xlog("ok", path)
        #     return file_wrapper(open(last_ok[2], "rb"))
        if environ["REQUEST_METHOD"] == "GET":
            cache = self.last_ok.get(path)
            if cache:
                start_response(cache[0], cache[1])
                file_wrapper = environ.get("wsgi.file_wrapper", FileWrapper)
                return file_wrapper(open(cache[2], "rb"))
        static_file = self.files.get(path)
        if static_file is None:
            return self.application(environ, start_response)
        else:
            return self.serve(static_file, environ, start_response)

    @staticmethod
    def serve(static_file, environ, start_response):
        response = static_file.get_response(environ["REQUEST_METHOD"], environ)
        status_line = "{} {}".format(response.status, response.status.phrase)
        start_response(status_line, list(response.headers))
        if response.file is not None:
            file_wrapper = environ.get("wsgi.file_wrapper", FileWrapper)
            return file_wrapper(response.file)
        else:
            return []

    def add_files(self, root, prefix=None):
        root = decode_if_byte_string(root, force_text=True)
        root = os.path.abspath(root)
        root = root.rstrip(os.path.sep)
        prefix = decode_if_byte_string(prefix)
        prefix = ensure_leading_trailing_slash(prefix)
        # xlog("in add_files", root)
        if os.path.isdir(root):
            self.update_files_dictionary(root, prefix)
        else:
            # xlog("No directory at:", root)
            warnings.warn("No directory at: {}".format(root))

    def update_files_dictionary(self, root, prefix):
        # Build a mapping from paths to the results of `os.stat` calls
        # so we only have to touch the filesystem once
        cdef string s_path
        # xlog("in update_files_dictionary")

        WNCache.scan_tree(self, root)
        # xlog(len(WNCache.stat_cache_keys(self)))
        for path in WNCache.stat_cache_keys(self):
            # xlog('--', path)
            relative_path = path[len(root) :]
            relative_url = relative_path.replace("\\", "/")
            while relative_url.startswith('/'):
                relative_url = relative_url[1:]
            url = prefix + relative_url
            self.add_file_to_dictionary(url, path)

    def add_file_to_dictionary(self, url, path):
        # xlog("add_file_to_dictionary", url, path)
        if self.is_compressed_variant_cache(path):
            return
        static_file = self.get_static_file_cache(path, url)
        # xlog("static_file is", static_file)
        self.last_ok[url] = static_file.check_response()
        self.files[url] = static_file

    def find_file(self, url):
        # Optimization: bail early if the URL can never match a file
        if not self.index_file and url.endswith("/"):
            return
        if not self.url_is_canonical(url):
            return
        for path in self.candidate_paths_for_url(url):
            try:
                return self.find_file_at_path(path, url)
            except MissingFileError:
                pass

    def candidate_paths_for_url(self, url):
        for root, prefix in self.directories:
            if url.startswith(prefix):
                path = os.path.join(root, url[len(prefix) :])
                if os.path.commonprefix((root, path)) == root:
                    yield path

    def find_file_at_path(self, path, url):
        if self.is_compressed_variant(path):
            raise MissingFileError(path)
        if self.index_file:
            return self.find_file_at_path_with_indexes(path, url)
        else:
            return self.get_static_file(path, url)

    def find_file_at_path_with_indexes(self, path, url):
        if url.endswith("/"):
            path = os.path.join(path, self.index_file)
            return self.get_static_file(path, url)
        elif url.endswith("/" + self.index_file):
            if os.path.isfile(path):
                return self.redirect(url, url[: -len(self.index_file)])
        else:
            try:
                return self.get_static_file(path, url)
            except IsDirectoryError:
                if os.path.isfile(os.path.join(path, self.index_file)):
                    return self.redirect(url, url + "/")
        raise MissingFileError(path)

    @staticmethod
    def url_is_canonical(url):
        """
        Check that the URL path is in canonical format i.e. has normalised
        slashes and no path traversal elements
        """
        if "\\" in url:
            return False
        normalised = normpath(url)
        if url.endswith("/") and url != "/":
            normalised += "/"
        return normalised == url

    @staticmethod
    def is_compressed_variant(path):
        if path[-3:] in (".gz", ".br"):
            uncompressed_path = path[:-3]
            return os.path.isfile(uncompressed_path)
        return False

    def is_compressed_variant_cache(self, path):
        if path[-3:] in (".gz", ".br"):
            uncompressed_path = path[:-3]

            # return py_to_string(uncompressed_path) in self.stat_cache_key_set(self)
            return WNCache.stat_cache_known_key(self, py_to_string(uncompressed_path))
        return False

    def get_static_file(self, path, url):
        # Optimization: bail early if file does not exist
        if not os.path.exists(path):
            raise MissingFileError(path)
        headers = Headers([])
        self.add_mime_headers(headers, path, url)
        self.add_cache_headers(headers, path, url)
        if self.allow_all_origins:
            headers["Access-Control-Allow-Origin"] = "*"
        if self.add_headers_function:
            self.add_headers_function(headers, path, url)
        return WNCache.c_make_static_file(self, path, headers.items())

    def get_static_file_cache(self, path, url):
        headers = Headers([])
        self.add_mime_headers(headers, path, url)
        self.add_cache_headers(headers, path, url)
        if self.allow_all_origins:
            headers["Access-Control-Allow-Origin"] = "*"
        if self.add_headers_function:
            self.add_headers_function(headers, path, url)
        return WNCache.c_make_static_file(self, path, headers.items())

    def add_mime_headers(self, headers, path, url):
        ## error: cyp_a_whitenoise/base.pyx:235:37:
        ## Object of type 'MediaTypes' has no attribute 'get_type'
        ## BUG: it does.
        # media_type = self.media_types.get_type(path)

        # media_type = c_wrap_get_type(self.media_types, path)
        media_type = self.media_types.get_type(path)

        # if media_type.startswith("text/"):
        #     params = {"charset": str(self.charset)}
        # else:
        #     params = {}
        # headers.add_header("Content-Type", str(media_type), **params)
        if media_type.startswith("text/"):
            headers.add_header("Content-Type", media_type, charset=self.charset)
        else:
            headers.add_header("Content-Type", media_type)

    def add_cache_headers(self, headers, path, url):
        if self.immutable_file_test(path, url):
            headers["Cache-Control"] = "max-age={0}, public, immutable".format(
                self.FOREVER
            )
        elif self.max_age is not None:
            headers["Cache-Control"] = "max-age={0}, public".format(self.max_age)

    def immutable_file_test(self, path, url):
        """
        This should be implemented by sub-classes (see e.g. WhiteNoiseMiddleware)
        or by setting the `immutable_file_test` config option
        """
        return False

    def redirect(self, from_url, to_url):
        """
        Return a relative 302 redirect

        We use relative redirects as we don't know the absolute URL the app is
        being hosted under
        """
        if to_url == from_url + "/":
            relative_url = from_url.split("/")[-1] + "/"
        elif from_url == to_url + self.index_file:
            relative_url = "./"
        else:
            raise ValueError("Cannot handle redirect: {} > {}".format(from_url, to_url))
        if self.max_age is not None:
            headers = {"Cache-Control": "max-age={0}, public".format(self.max_age)}
        else:
            headers = {}
        return Redirect(relative_url, headers=headers)


#
# cdef Str to_str2(byte_or_string):
#     if isinstance(byte_or_string, str):
#         return Str(byte_or_string.encode("utf8"))
#     else:
#         return Str(bytes(byte_or_string))


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


#
# cdef Toto make_media_types(dict mimetypes):
# # cdef MediaTypes make_media_types(dict mimetypes):
#     cdef Sdict c_mt
#     cdef Toto response
#     # cdef MediaTypes response
#
#     if mimetypes:
#         c_mt = to_str_dict(mimetypes)
#     else:
#         c_mt = Sdict()
#
#     # return MediaTypes(c_mt)
#     return Toto(c_mt)