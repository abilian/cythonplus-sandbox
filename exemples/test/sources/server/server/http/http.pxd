from stdlib.string cimport Str
from libcythonplus.dict cimport cypdict


cdef cypclass HTTPRequest:
    Str raw
    Str method
    Str uri
    Str version
    cypdict[Str, Str] headers
    int _pos
    bint ok

    __init__(self, Str request):
        self.headers = cypdict[Str, Str]()
        self.raw = request
        self.ok = True
        self.parse()

    int whitespace(self):
        cdef int i = self._pos
        cdef int l = self.raw.__len__()
        cdef int n
        while i < l:
            c = self.raw[i]
            # space or tab
            if c == <char> 32 or c == <char> 9:
                i += 1
                continue
            break
        n = i - self._pos
        self._pos = i
        return n

    int rstrip(self, int start, int stop):
        while stop > start:
            c = self.raw[stop - 1]
            # space or tab
            if c == <char> 32 or c == <char> 9:
                stop -= 1
                continue
            break
        return stop

    int peek(self, Str sentinel, int stop=0):
        return self.raw.find(sentinel, self._pos, stop)

    void skip(self, Str sentinel, int start=-1):
        if start < self._pos:
            start = self._pos
        self._pos = start + sentinel.__len__()

    Str step(self, int stop):
        cdef int start = self._pos
        self._pos = stop
        return self.raw.substr(start, stop)

    Str token(self, Str sentinel, int stop=0):
        cdef int start = self._pos
        stop = self.peek(sentinel, stop)
        if stop == -1:
            return NULL
        self._pos = stop + sentinel.__len__()
        return self.raw.substr(start, stop)

    void error(self):
        self.ok = False

    void parse(self):
        cdef Str SP = Str(' ')
        cdef Str CRLF = Str('\r\n')
        cdef Str COL = Str(':')
        cdef int end = self.raw.__len__()
        self._pos = 0
        endline = self.peek(CRLF)
        method = self.token(SP, endline)
        if method is NULL:
            self.error()
            return
        self.method = method
        uri = self.token(SP, endline)
        if uri is NULL:
            self.error()
            return
        self.uri = uri
        version = self.token(CRLF)
        if version is NULL:
            self.error()
            return
        self.version = version
        while self._pos < end:
            endline = self.peek(CRLF)
            if endline == self._pos:
                self.skip(CRLF)
                break
            key = self.token(COL, endline)
            if key is NULL:
                self.error()
                return
            self.whitespace()
            stop = self.rstrip(self._pos, endline)
            if stop <= self._pos:
                self.error()
                return
            value = self.raw.substr(self._pos, stop)
            self.skip(CRLF, endline)
            self.headers[key] = value

