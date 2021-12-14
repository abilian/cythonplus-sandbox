from libcythonplus.dict cimport cypdict
from stdlib.string cimport Str
from .common cimport Sdict


cdef cypclass MediaTypes:
    Sdict types_map

    __init__(self, Sdict extra_types):
        self.types_map = default_types()
        if extra_types is not NULL:
            self.types_map.update(extra_types)

    Str get_type(self, Str path):
        cdef Str ext

        if path in self.types_map:
            return self.types_map[path]
        ext = extension(path)
        if ext in self.types_map:
            return self.types_map[ext]
        return Str("application/octet-stream")


cdef Str extension(Str filename) nogil
cdef Sdict default_types() nogil
