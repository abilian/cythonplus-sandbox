# distutils: language = c++
import os
from posixpath import normpath
import re
import warnings
from wsgiref.headers import Headers
from wsgiref.util import FileWrapper

from libcythonplus.dict cimport cypdict
from stdlib.string cimport Str

from .media_types cimport MediaTypes, Sdict#, c_wrap_get_type
from .responders import StaticFile, MissingFileError, IsDirectoryError, Redirect
from .string_utils import (
    decode_if_byte_string,
    decode_path_info,
    ensure_leading_trailing_slash,
)


# cdef class WhiteNoise():
class WhiteNoise():
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
        if root is not None:
            self.add_files(root, prefix)

    def __call__(self, environ, start_response):
        path = decode_path_info(environ.get("PATH_INFO", ""))
        if self.autorefresh:
            static_file = self.find_file(path)
        else:
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
        root = root.rstrip(os.path.sep) + os.path.sep
        prefix = decode_if_byte_string(prefix)
        prefix = ensure_leading_trailing_slash(prefix)
        if self.autorefresh:
            # Later calls to `add_files` overwrite earlier ones, hence we need
            # to store the list of directories in reverse order so later ones
            # match first when they're checked in "autorefresh" mode
            self.directories.insert(0, (root, prefix))
        else:
            if os.path.isdir(root):
                self.update_files_dictionary(root, prefix)
            else:
                warnings.warn("No directory at: {}".format(root))

    def update_files_dictionary(self, root, prefix):
        # Build a mapping from paths to the results of `os.stat` calls
        # so we only have to touch the filesystem once
        stat_cache = dict(scantree(root))
        for path in stat_cache.keys():
            relative_path = path[len(root) :]
            relative_url = relative_path.replace("\\", "/")
            url = prefix + relative_url
            self.add_file_to_dictionary(url, path, stat_cache)

    def add_file_to_dictionary(self, url, path, stat_cache):
        if self.is_compressed_variant_cache(path, stat_cache):
            return
        if self.index_file and url.endswith("/" + self.index_file):
            index_url = url[: -len(self.index_file)]
            index_no_slash = index_url.rstrip("/")
            self.files[url] = self.redirect(url, index_url)
            self.files[index_no_slash] = self.redirect(index_no_slash, index_url)
            url = index_url
        static_file = self.get_static_file_cache(path, url, stat_cache)
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

    @staticmethod
    def is_compressed_variant_cache(path, stat_cache):
        if path[-3:] in (".gz", ".br"):
            uncompressed_path = path[:-3]
            return uncompressed_path in stat_cache
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
        return StaticFile(
            path,
            headers.items(),
            stat_cache=None,
        )

    def get_static_file_cache(self, path, url, stat_cache):
        headers = Headers([])
        self.add_mime_headers(headers, path, url)
        self.add_cache_headers(headers, path, url)
        if self.allow_all_origins:
            headers["Access-Control-Allow-Origin"] = "*"
        if self.add_headers_function:
            self.add_headers_function(headers, path, url)
        return StaticFile(
            path,
            headers.items(),
            stat_cache=stat_cache,
        )

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


def scantree(root):
    """
    Recurse the given directory yielding (pathname, os.stat(pathname)) pairs
    """
    for entry in os.scandir(root):
        if entry.is_dir():
            yield from scantree(entry.path)
        else:
            yield entry.path, entry.stat()


cdef Str to_str(byte_or_string):
    """(need gil)
    """
    if isinstance(byte_or_string, str):
        return Str(bytes(byte_or_string.encode("utf8")))
    else:
        return Str(bytes(byte_or_string))


cdef from_str(Str s):
    return s.bytes().decode("utf8", 'replace')


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
