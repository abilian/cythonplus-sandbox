from libcythonplus.dict cimport cypdict
from stdlib.string cimport string as Str

ctypedef cypdict[Str, Str] Sdict


cdef cypclass MediaTypes:
    Sdict types_map
    ## BUG 'default' not valid attribute name here
    ## => simplify code

    __init__(self, Sdict extra_types):
        self.types_map = default_types()
        # self.default_type = Str("application/octet-stream")
        self.types_map.update(extra_types)

    Str get_type(self, Str path):
        cdef Str ext

        # name = os.path.basename(path).lower()  # no lower, duplicete keys in dict
        # media_type = self.types_map.get(path)
        if path in self.types_map:
            return self.types_map[path]
        # extension = os.path.splitext(path)[1]
        ext = extension(path)
        if ext in self.types_map:
            return self.types_map[ext]
        return Str("application/octet-stream")


cdef Str c_wrap_get_type(MediaTypes mt, Str path) nogil

cdef Str extension(Str filename) nogil

cdef Sdict default_types() nogil
