import os
from posixpath import normpath
import re
import sys
import warnings

from libcythonplus.dict cimport cypdict
from libc.stdio cimport *
# from posix.time cimport nanosleep, timespec

from stdlib.string cimport Str
from stdlib._string cimport string
from stdlib.format cimport format

from .stdlib.abspath cimport abspath
from .stdlib.startswith cimport startswith, endswith
from .stdlib.strip cimport stripped
from .stdlib.regex cimport re_is_match
from .stdlib.formatdate cimport formatnow

from stdlib.socket cimport *
from stdlib.http cimport HTTPRequest

from scheduler.scheduler cimport SequentialMailBox, NullResult, Scheduler

from .common cimport getdefault, StrList, Finfo, Fdict
from .common cimport xlog
from .http_status cimport get_status_line
from .http_headers cimport HttpHeaders, cyp_environ_headers, hash_headers
from .media_types cimport MediaTypes
from .scan cimport scan_fs_dic
from .static_file cimport StaticFile
from .response cimport Response


ctypedef cypdict[string, StaticFile] StaticFileCache
# Use global for static files (responses) cache:
cdef StaticFileCache[1] global_files
# Use global for scheduler:
cdef lock Scheduler server_scheduler


cdef cypclass Responder activable:
    Socket s1

    __init__(self,  iso Socket s1):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(server_scheduler)
        self.s1 = consume s1

    Str response_404(self, Str path):
        cdef Str html, body, now
        cdef int length

        body = format("<html><head><title>404 Not Found</title><style>body {{background-color: white}}</style></head><body><h1>404 Not Found</h1><h3><br>{}</h3></body></html>\r\n", path)
        length = body.__len__()
        now = formatnow()
        html = format("HTTP/1.1 404 Not Found\r\nServer: staticsimple 0.2\r\nDate: {}\r\nConnection: keep-alive\r\nContent-Type: text/html\r\nContent-Length: {}\r\n\r\n{}",
        now, length, body)
        return html

    void send_response(self, Response response):
        cdef Str head, now, status, header_lines, path
        cdef FILE * file
        cdef char * buffer
        cdef size_t length

        now = formatnow()
        status = response.status_line
        length = response.length
        path = response.file_path
        # with gil:
        #     xlog(response.status_line.bytes())
        #     xlog(response.length)
        header_lines = response.headers.get_text()  # ended with one \r\n
        head = format("HTTP/1.1 {}\r\nServer: staticsimple 0.2\r\nDate: {}\r\n{}\r\n",
                        status,
                        now,
                        header_lines)
        self.s1.sendall(head)
        if path is NULL:  # probably a HEAD method
            return

        file = fopen(path._str.c_str(), "rb")
        if file:
            # fseek(file, 0, SEEK_END)
            # length = ftell(file)
            # fseek(file, 0, SEEK_SET)
            buffer = <char*>malloc(length)
            if buffer:
                fread(buffer, 1, length, file)
                self.s1.sendraw(buffer, length)
                free(buffer)
            fclose(file)

    void run(self):
        cdef Str body, resp, status, rq, method
        cdef size_t length
        cdef Str crlfcrlf = Str("\r\n\r\n")
        cdef HTTPRequest request
        cdef Str recv
        cdef Response response

        cdef StaticFileCache files = global_files[0]
        cdef StaticFile static_file

        recv = Str.copy_iso(self.s1.recvuntil(crlfcrlf, 1024))
        request = HTTPRequest(recv)

        if not request.ok:
            # with gil:
            #     xlog(f"bad request")
            del request
            self.s1.shutdown(SHUT_WR)
            self.s1.close()
            return

        # assuming  method is GET or HEAD:
        if <string> request.uri._str not in files:
            resp = self.response_404(request.uri)
            self.s1.sendall(resp)
            del request
            self.s1.shutdown(SHUT_WR)
            self.s1.close()
            return
        # with gil:
        #     xlog(request.uri.bytes())
        static_file = files[<string> request.uri._str]
        response = static_file.get_response2(request.method, request.headers)
        self.send_response(response)
        del request
        self.s1.shutdown(SHUT_WR)
        self.s1.close()
        # with gil:
        #     xlog("send done")


cdef cypclass Noise:
    Fdict stat_cache
    int max_age
    bint allow_all_origins
    Str charset
    cypdict[Str, Str] mimetypes
    Str add_headers_function
    Str root
    Str prefix
    MediaTypes media_types
    int nb_files

    __init__(self):
        self.stat_cache = NULL
        self.max_age = 60
        self.allow_all_origins = True
        self.charset = Str("utf-8")
        self.mimetypes = NULL  # always NULL for his implementation
        self.add_headers_function = NULL
        self.nb_files = 0

    void start(self, Str root, Str prefix):
        self.root = root
        self.prefix = prefix
        self.media_types = MediaTypes(self.mimetypes)
        self.add_files()

    void add_files(self):
        cdef Str url, path
        cdef StaticFileCache files

        global global_files
        files = StaticFileCache()

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
        self.stat_cache = scan_fs_dic(self.root)

        for cpath in self.stat_cache.keys():
            path = new Str()
            path._str = <string> cpath
            if self.is_compressed_variant_cache(path):
                continue
            relative_path = path.substr(root.__len__())
            while startswith(relative_path, Str("/")):
                relative_path = relative_path.substr(1)
            url = prefix + relative_path
            files[<string> url._str] = self.get_static_file_cache(path, url)

        self.nb_files = files.__len__()
        # store to global:
        global_files[0] = files

    bint is_compressed_variant_cache(self, Str path):
        cdef Str uncompressed_path
        cdef string tmp

        if endswith(path, Str(".gz")) or endswith(path, Str(".br")):
            uncompressed_path = path.substr(0, -3)
            tmp = <string> uncompressed_path._str
            if tmp in self.stat_cache:
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
        # See later for this:
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


cdef Str to_str(byte_or_string)
