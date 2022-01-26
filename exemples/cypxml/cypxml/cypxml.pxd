from stdlib.string cimport Str
from stdlib._string cimport string
from stdlib.format cimport format
from libcythonplus.dict cimport cypdict
from libcythonplus.list cimport cyplist

from .stdlib.xml_utils cimport replace_one, replace_all
from .stdlib.xml_utils cimport escape, unescape
from .stdlib.xml_utils cimport quoteattr
from .stdlib.xml_utils cimport nameprep


cdef cypclass cypXML:
    """A cypclass providing basic XML document API
    """
    cyplist[Str] doc  # a list of lines

    __init__(self):
        self.doc = cyplist[Str]()


cdef cypclass cypElement:
    """A cypclass providing basic XML element API
    """
    Str name

    __init__(self, Str name):
        self.name = nameprep(name)


cdef Str to_str(byte_or_string)
