from collections import namedtuple
from email.utils import formatdate, parsedate
import errno

from http import HTTPStatus
import os
import stat
from time import mktime
from urllib.parse import quote

from wsgiref.headers import Headers

from libcythonplus.dict cimport cypdict
from stdlib._string cimport string
from stdlib.string cimport Str

from .common cimport StrList
from .header_list cimport HeaderList
from stdlib.regex cimport regex_t, regmatch_t, regcomp, regexec, regfree
from stdlib.regex cimport REG_EXTENDED

from .scan cimport Finfo, Fdict, from_str, to_str
from .http_status cimport HttpStatus, HttpStatusDict, generate_http_status_dict


# Response = namedtuple("Response", ("status", "headers", "file"))
cdef HttpStatusDict HSD = generate_http_status_dict()


cdef Response NOT_ALLOWED_RESPONSE = Response(
        HSD[Str("METHOD_NOT_ALLOWED")],
        gen_header_list(Str("Allow"), Str("GET, HEAD")),
        Str("")
)

cdef StrList NOT_MODIFIED_HEADERS
# Headers which should be returned with a 304 Not Modified response as
# specified here: https://tools.ietf.org/html/rfc7232#section-4.1
NOT_MODIFIED_HEADERS = gen_not_modified_headers()


cdef HeaderList gen_header_list(Str k, Str v) nogil:
    cdef HeaderList header_list

    header_list = HeaderList()
    header_list.add_header(k, v)
    return header_list


cdef StrList gen_not_modified_headers() nogil:
    cdef StrList nmh

    nmh = StrList()
    nmh.append(Str("Cache-Control"))
    nmh.append(Str("Content-Location"))
    nmh.append(Str("Date"))
    nmh.append(Str("ETag"))
    nmh.append(Str("Expires"))
    nmh.append(Str("Vary"))
    return nmh


cdef Str re_bound = Str("[ :,;?()\"']")


cdef bint re_match(Str pattern, Str target) nogil:
    cdef regex_t regex
    cdef int result
    # cdef regmatch_t  pmatch[1]

    if regcomp(&regex, pattern.bytes(), REG_EXTENDED):
        with gil:
            raise ValueError(f"regcomp failed on {pattern.bytes()}")

    if not regexec(&regex, target.bytes(), 0, NULL, 0):
        return 1
    return 0


# cdef AlternativeList get_alternatives(base_headers, files) nogil:
#     cdef Str encoding_pattern, encoding
#     cdef AlternativeList alternatives
#     # Sort by size so that the smallest compressed alternative matches first
#     alternatives = AlternativeList()
#     # files_by_size = sorted(files.items(), key=lambda i: i[1].stat.st_size)
#     # for encoding, file_entry in files.items():
#     for item in files.items():
#         encoding = item.first
#         file_entry = item.second
#         headers = Headers(base_headers.items())
#         headers["Content-Length"] = str(file_entry[0])
#         if encoding:
#             headers["Content-Encoding"] = encoding
#             #encoding_re = re.compile(r"\b%s\b" % encoding)
#             encoding_pattern = re_bound + encoding + re_bound
#         else:
#             encoding_pattern = Str("")
#         alternatives.append((encoding_pattern, file_entry[2], headers.items()))
#     return alternatives


cdef StaticFile make_static_file(Str path, HeaderList headers_list, Fdict stat_cache) nogil:
    # cdef Fdict files = Fdict()  # FIXMe not a Fdict
    cdef StrList files = StrList()
    # files = file_stats(to_str(path), stat_cache)

    return StaticFile(path, headers_list, files)


# class StaticFile:
#     def __init__(self, path, headers_list, files):
#         # self.stat_cache = stat_cache
#         # encodings = {"gzip": path + ".gz", "br": path + ".br"}
#         # files = self.get_file_stats(path, encodings)
#         headers = self.get_headers(headers_list, files)
#         self.last_modified = parsedate(headers["Last-Modified"])
#         self.etag = headers["ETag"]
#         self.not_modified_response = self.get_not_modified_response(headers)
#         self.alternatives = get_alternatives(headers, files)
#
#     def get_response(self, method, request_headers):
#         if method not in ("GET", "HEAD"):
#             return NOT_ALLOWED_RESPONSE
#         if self.is_not_modified(request_headers):
#             return self.not_modified_response
#         path, headers = self.get_path_and_headers(request_headers)
#         if method != "HEAD":
#             file_handle = open(path, "rb")
#         else:
#             file_handle = None
#         range_header = request_headers.get("HTTP_RANGE")
#         if range_header:
#             try:
#                 return self.get_range_response(range_header, headers, file_handle)
#             except ValueError:
#                 # If we can't interpret the Range request for any reason then
#                 # just ignore it and return the standard response (this
#                 # behaviour is allowed by the spec)
#                 pass
#         return Response(HTTPStatus.OK, headers, file_handle)
#
#     def get_range_response(self, range_header, base_headers, file_handle):
#         headers = []
#         for item in base_headers:
#             if item[0] == "Content-Length":
#                 size = int(item[1])
#             else:
#                 headers.append(item)
#         start, end = self.get_byte_range(range_header, size)
#         if start >= end:
#             return self.get_range_not_satisfiable_response(file_handle, size)
#         if file_handle is not None and start != 0:
#             file_handle.seek(start)
#         headers.append(("Content-Range", "bytes {}-{}/{}".format(start, end, size)))
#         headers.append(("Content-Length", str(end - start + 1)))
#         return Response(HTTPStatus.PARTIAL_CONTENT, headers, file_handle)
#
#     def get_byte_range(self, range_header, size):
#         start, end = self.parse_byte_range(range_header)
#         if start < 0:
#             start = max(start + size, 0)
#         if end is None:
#             end = size - 1
#         else:
#             end = min(end, size - 1)
#         return start, end
#
#     @staticmethod
#     def parse_byte_range(range_header):
#         units, _, range_spec = range_header.strip().partition("=")
#         if units != "bytes":
#             raise ValueError()
#         # Only handle a single range spec. Multiple ranges will trigger a
#         # ValueError below which will result in the Range header being ignored
#         start_str, sep, end_str = range_spec.strip().partition("-")
#         if not sep:
#             raise ValueError()
#         if not start_str:
#             start = -int(end_str)
#             end = None
#         else:
#             start = int(start_str)
#             end = int(end_str) if end_str else None
#         return start, end
#
#     @staticmethod
#     def get_range_not_satisfiable_response(file_handle, size):
#         if file_handle is not None:
#             file_handle.close()
#         return Response(
#             HTTPStatus.REQUESTED_RANGE_NOT_SATISFIABLE,
#             [("Content-Range", "bytes */{}".format(size))],
#             None,
#         )
#
#     def get_headers(self, headers_list, files):
#         headers = Headers(headers_list)
#         main_file = files[""]
#         if len(files) > 1:
#             headers["Vary"] = "Accept-Encoding"
#         if "Last-Modified" not in headers:
#             mtime = main_file[1]
#             # Not all filesystems report mtimes, and sometimes they report an
#             # mtime of 0 which we know is incorrect
#             if mtime:
#                 headers["Last-Modified"] = formatdate(mtime, usegmt=True)
#         if "ETag" not in headers:
#             last_modified = parsedate(headers["Last-Modified"])
#             if last_modified:
#                 timestamp = int(mktime(last_modified))
#                 headers["ETag"] = '"{:x}-{:x}"'.format(
#                     timestamp, main_file[0]
#                 )
#         return headers
#
#     @staticmethod
#     def get_not_modified_response(headers):
#         not_modified_headers = []
#         for key in NOT_MODIFIED_HEADERS:
#             if key in headers:
#                 not_modified_headers.append((key, headers[key]))
#         return Response(
#             status=HTTPStatus.NOT_MODIFIED, headers=not_modified_headers, file=None
#         )
#
#
#     def is_not_modified(self, request_headers):
#         previous_etag = request_headers.get("HTTP_IF_NONE_MATCH")
#         if previous_etag is not None:
#             return previous_etag == self.etag
#         if self.last_modified is None:
#             return False
#         try:
#             last_requested = request_headers["HTTP_IF_MODIFIED_SINCE"]
#         except KeyError:
#             return False
#         last_requested_ts = parsedate(last_requested)
#         if last_requested_ts is not None:
#             return parsedate(last_requested) >= self.last_modified
#         return False
#
#     def get_path_and_headers(self, request_headers):
#         accept_encoding = request_headers.get("HTTP_ACCEPT_ENCODING", "")
#         # These are sorted by size so first match is the best
#         for encoding_pattern, path, headers in self.alternatives:
#             # if encoding_re.search(accept_encoding):
#             #     return path, headers
#             if re_match(encoding_pattern, Str(accept_encoding.encode("utf8"))):
#                 return path, headers
#

class NotARegularFileError(Exception):
    pass


class MissingFileError(NotARegularFileError):
    pass


class IsDirectoryError(MissingFileError):
    pass

#
# cdef file_stats(Str path, Fdict stat_cache):
#     cdef Finfo info
#     cdef Str zpath
#
#     if path._str in stat_cache:
#         info = stat_cache[path._str]
#         files = [(info.size, info.mtime, from_str(path), "")]
#     else:
#         # with gil:
#         raise MissingFileError(from_str(path))
#     zpath = path + Str(".gz")
#     if zpath._str in stat_cache:
#         info = stat_cache[zpath._str]
#         files.append((info.size, info.mtime, from_str(zpath), Str("gzip")))
#     zpath = path + Str(".br")
#     if zpath._str in stat_cache:
#         info = stat_cache[zpath._str]
#         files.append((info.size, info.mtime, from_str(zpath), Str("br")))
#
#     return {f[3]: (f[0], f[1], f[2]) for f in sorted(files)}
