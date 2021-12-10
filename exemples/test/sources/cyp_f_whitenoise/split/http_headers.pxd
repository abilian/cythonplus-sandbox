#!/usr/bin/env python
"""https headers, managed like flask Headers
"""
from libcythonplus.dict cimport cypdict
from libcythonplus.list cimport cyplist
from stdlib.string cimport Str
from stdlib.format cimport format
from .stdlib.strip cimport stripped


cdef cypclass HttpHeaderLine:
    Str key
    Str value

    __init__(self, Str key, Str value):
        self.key = key
        self.value = value

    cyplist[Str] splitted(self):
        cdef cyplist[Str] lst, lst_result
        cdef Str s, r

        lst = self.value.split(Str(","))
        lst_result = cyplist[Str]()
        for s in lst:
            r = stripped(s)
            if r is not NULL and r.__len__() > 0:
                lst_result.append(r)

    void add(self, Str value)
        cdef Str s, comma
        cdef cyplist[Str] lst

        if value is NULL:
            return
        s = stripped(value)
        if s.__len__() == 0:
            return

        lst = self.splitted()
        lst.append(s)
        comma = Str(", ")
        self.value = comma.join(lst)

    void set(self, Str value)
        self.value = value


cdef cypclass HttpHeaders:
    cypdict[HttpHeaderLine] headers

    __init__(self):
        self.headers = cypdict[HttpHeaderLine]()
