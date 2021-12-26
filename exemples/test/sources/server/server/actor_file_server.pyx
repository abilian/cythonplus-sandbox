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


cdef Str to_str(byte_or_string):
    if isinstance(byte_or_string, str):
        return Str(byte_or_string.encode("utf8", "replace"))
    else:
        return Str(bytes(byte_or_string))


class ActorFileServer:
    def __init__(self, py_server_addr, py_server_port,
                 py_root=None, py_prefix=None, py_back_log=1):

        self.py_server_addr = py_server_addr
        self.py_server_port = py_server_port
        self.py_root = py_root
        self.py_prefix = py_prefix
        self.backlog = int(py_back_log)
        self.nb_files = 0

    def scan(self):
        cdef Noise noise
        cdef Str root, prefix

        if self.py_root:
            root = to_str(self.py_root)
        else:
            root = NULL
        if self.py_prefix is not None:
            prefix = to_str(self.py_prefix)
        else:
            prefix = Str("")

        noise = Noise()
        with nogil:
            noise.start(root, prefix)

        self.nb_files = noise.nb_files
        xlog(f"files cached: {self.nb_files}")

    def nb_cached_files(self):
        return self.nb_files

    def serve(self):
        cdef Str server_addr, server_port
        cdef Socket s1
        cdef int backlog
        cdef int count
        global server_scheduler
        cdef int pending

        server_scheduler = Scheduler()
        server_addr = to_str(self.py_server_addr)
        server_port = to_str(self.py_server_port)
        backlog = <int> self.backlog

        count = 0
        with nogil:
            a = getaddrinfo(server_addr, server_port,
                            AF_UNSPEC, SOCK_STREAM, 0, AI_PASSIVE)[0]
            s = socket(a.family, a.socktype, a.protocol)
            s.setsockopt(SO_REUSEADDR, 1)
            s.bind(a.sockaddr)
            s.listen(backlog)

            with gil:
                xlog(f"listening on "
                     f"http://{self.py_server_addr}:{self.py_server_port}")
                xlog("initialization ok.")

            loop = True
            while loop:
                # with gil:
                #     xlog(f"--- in loop ")
                #     pending = server_scheduler.num_pending_queues.load()
                #     xlog(pending)
                with gil:
                    try:
                        with nogil:
                            s1 = s.accept()
                    except OSError as e:
                        xlog(f"error: {e}")
                        continue

                active_r = activate(consume(Responder(consume s1)))
                active_r.run(NULL)
                count += 1
                if count % 10000 == 0:
                    with gil:
                        xlog(f"counter: {count}")
            s.close()
