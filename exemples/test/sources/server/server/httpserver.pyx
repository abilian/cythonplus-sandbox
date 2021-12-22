from stdlib.string cimport Str
from stdlib.format cimport format
from http.socket cimport *
from http.http cimport HTTPRequest

from libc.stdio cimport puts, printf


def httpserver(py_server_addr, py_server_port):
    cdef Str recv, body, resp
    cdef size_t length
    cdef Str CRLFCRLF = Str("\r\n\r\n")
    cdef Str server_addr, server_port

    server_addr = Str(py_server_addr.encode("utf8"))
    server_port = Str(py_server_port.encode("utf8"))
    with nogil:
        a = getaddrinfo(server_addr, server_port,
                        AF_UNSPEC, SOCK_STREAM, 0, AI_PASSIVE)[0]

        s = socket(a.family, a.socktype, a.protocol)

        s.setsockopt(SO_REUSEADDR, 1)

        s.bind(a.sockaddr)

        s.listen(5)

        printf("listening on http://%s:%s\n", a.sockaddr.to_string().bytes(), server_port.bytes())

        loop = True
        while loop:
            with gil:
                try:
                    with nogil:
                        s1 = s.accept()
                except OSError as e:
                    print(e)
                    continue

            recv = s1.recvuntil(CRLFCRLF, 1024)
            printf('Received:\n==========\n%s\n==========\n\n', Str.to_c_str(recv))

            request = HTTPRequest(recv)

            if request.ok:
                status = Str("HTTP/1.0 200 OK")
                content_length_key = Str('Content-Length')
                if content_length_key in request.headers:
                    content_length_value = request.headers[content_length_key]
                    length = content_length_value.__int__()
                    body = recv.substr(request._pos)
                    while body.__len__() < length:
                        remaining = length - body.__len__()
                        body = s1.recvinto(consume body, remaining)
                    printf('Received body:\n==========\n%s\n==========\n\n', Str.to_c_str(body))
                    resp = format("{}\r\nContent-Length: {}{}{}", status, length, CRLFCRLF, body)

                    if body == Str("quit"):
                        loop = False

                else:
                    resp = status + CRLFCRLF

            else:
                if recv == Str('quit'):
                    loop = False

                status = Str("HTTP/1.0 418 I'M A TEAPOT")
                resp = status + CRLFCRLF

            printf("Sending:\n==========\n%s\n==========\n\n\n", Str.to_c_str(resp))
            s1.sendall(resp)

            s1.shutdown(SHUT_WR)

            s1.close()

        s.close()
