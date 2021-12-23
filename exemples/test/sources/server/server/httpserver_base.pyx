from stdlib.string cimport Str
from stdlib.format cimport format
from stdlib.socket cimport *
from stdlib.http cimport HTTPRequest

from libc.stdio cimport puts, printf

from scheduler.scheduler cimport SequentialMailBox, NullResult, Scheduler

from .common cimport xlog

# Use global for scheduler:
cdef lock Scheduler scheduler


cdef cypclass Responder activable:
    Socket s1

    __init__(self,  iso Socket s1):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.s1 = consume s1

    void run(self):
        cdef Str body, resp, status, rq
        cdef size_t length
        cdef Str crlfcrlf = Str("\r\n\r\n")
        cdef HTTPRequest request
        cdef iso Str recv

        recv = self.s1.recvuntil(crlfcrlf, 1024)
        # with gil:
        #     xlog(f"rq: {bytes(recv.bytes())}")
        request = HTTPRequest(consume recv)
        if not request.ok:
            with gil:
                xlog(f"bad request\n")
            self.s1.shutdown(SHUT_WR)
            self.s1.close()
            return

        # with gil:
        #     xlog(f"request: {request.headers.__len__()}")
        #     xlog(f"{bytes(request.method.bytes())}  {bytes(request.uri.bytes())}")
        # for item in request.headers.items():
        #     with gil:
        #         xlog(f"  -- {bytes(item.first.bytes())}: {bytes(item.second.bytes())}")
        # with gil:
        #     xlog(f"===\n")

            # rq = request.headers[Str("GET")]

        # if request.ok:
        status = Str("HTTP/1.0 200 OK")
            # content_length_key = Str('Content-Length')
            # if content_length_key in request.headers:
            #     content_length_value = request.headers[content_length_key]
            #     length = content_length_value.__int__()
            #     body = recv.substr(request._pos)
            #     while body.__len__() < length:
            #         remaining = length - body.__len__()
            #         body = s1.recvinto(consume body, remaining)
            #     printf('Received body:\n==========\n%s\n==========\n\n', Str.to_c_str(body))
            #     resp = format("{}\r\nContent-Length: {}{}{}", status, length, CRLFCRLF, body)
            #
            #     if body == Str("quit"):
            #         loop = False
            #
            # else:
        body = Str("Something")
        resp = format("{}\r\nContent-Length: {}{}{}", status, body.__len__(), crlfcrlf, body)
        # with gil:
        #     xlog(f"{bytes(resp.bytes())}")

        # resp = status + crlfcrlf
        # else:
        #     if recv == Str('quit'):
        #         loop = False
        #     status = Str("HTTP/1.0 418 I'M A TEAPOT")
        #     resp = status + CRLFCRLF
        # printf("Sending:\n==========\n%s\n==========\n\n\n", Str.to_c_str(resp))
        # with gil:
        #     xlog(f"sending")
        self.s1.sendall(resp)
        self.s1.shutdown(SHUT_WR)
        self.s1.close()
        # with gil:
        #     xlog(f"closed")


def httpserver(py_server_addr, py_server_port):
    cdef Str recv, body, resp
    cdef size_t length
    cdef Str CRLFCRLF = Str("\r\n\r\n")
    cdef Str server_addr, server_port
    cdef Socket s1
    global scheduler

    scheduler = Scheduler()
    server_addr = Str(py_server_addr.encode("utf8"))
    server_port = Str(py_server_port.encode("utf8"))
    with nogil:
        a = getaddrinfo(server_addr, server_port,
                        AF_UNSPEC, SOCK_STREAM, 0, AI_PASSIVE)[0]
        s = socket(a.family, a.socktype, a.protocol)
        s.setsockopt(SO_REUSEADDR, 1)
        s.bind(a.sockaddr)
        s.listen(100)

        with gil:
            xlog(f"listening on http://{py_server_addr}:{py_server_port}")
            xlog("initialization ok.")

        loop = True
        while loop:
            with gil:
                try:
                    with nogil:
                        s1 = s.accept()
                except OSError as e:
                    xlog(f"some error: {e}")
                    continue

            # r = Responder(consume s1)
            # with gil:
            #     xlog(f"-----------------")
            active_r = activate(consume(Responder(consume s1)))
            active_r.run(NULL)
            # with gil:
            #     xlog(f"-- next")

        s.close()
    xlog(f"quitting.")
