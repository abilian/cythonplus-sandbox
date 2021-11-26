from libcythonplus.dict cimport cypdict
from stdlib.string cimport Str

ctypedef cypdict[const char*, const char*] Sdict


cdef cypclass MediaTypes:
    Sdict types_map
    ## BUG 'default' not valid attribute name here
    ## => simplify code

    __init__(self, Sdict extra_types):
        self.types_map = default_types()
        # self.default_type = Str("application/octet-stream")
        self.types_map.update(extra_types)

    const char* get_type(self, Str path):
        cdef const char* ext

        # name = os.path.basename(path).lower()  # no lower, duplicete keys in dict
        # media_type = self.types_map.get(path)
        if Str.to_c_str(path) in self.types_map:
            return self.types_map[Str.to_c_str(path)]
        # extension = os.path.splitext(path)[1]
        ext = extension(path)
        if ext in self.types_map:
            return self.types_map[ext]
        return b"application/octet-stream"


# cdef const char* c_wrap_get_type(MediaTypes mt, Str path) nogil

cdef const char* extension(Str filename) nogil

cdef Sdict default_types() nogil
