#!/usr/bin/env python
"""python's http status table
"""
from libcythonplus.dict cimport cypdict
from stdlib.string cimport Str


cdef cypclass HttpStatus:
    int value
    Str phrase
    Str description

    __init__(self, int value, Str phrase, Str description):
        self.value = value
        self.phrase = phrase
        self.description = description

    Str status_line(self):
        return Str(self.value) + Str(" ") + self.phrase


ctypedef HttpStatusDict cypdict[Str, HttpStatus]

cdef HttpStatusDict generate_http_status_dict() nogil
