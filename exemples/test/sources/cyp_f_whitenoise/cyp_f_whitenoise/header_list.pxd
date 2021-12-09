from libcythonplus.list cimport cyplist
from stdlib.string cimport Str


cdef cypclass StrPair:
    Str first
    Str second

    __init__(self, Str a, Str b):
        self.first = a
        self.second = b


ctypedef cyplist[StrPair] PairList


cdef cypclass HeaderList:
    PairList plist

    __init__(self):
    self.plist = PairList()

    void add_header(self, Str key, Str value):
        cdef StrPair p

        p = StrPair(key, value)
        self.plist.append(p)

    void add_header_charset(self, Str key, Str value, Str charset):
        cdef StrPair p

        p = StrPair(key, value + Str("; charset=" + charset)
        self.plist.append(p)
