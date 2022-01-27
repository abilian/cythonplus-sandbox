from stdlib.string cimport Str
from stdlib._string cimport string
from stdlib.format cimport format
from libcythonplus.dict cimport cypdict
from libcythonplus.list cimport cyplist

from .stdlib.xml_utils cimport replace_one, replace_all
from .stdlib.xml_utils cimport escaped
from .stdlib.xml_utils cimport quoteattr, nameprep
from .stdlib.xml_utils cimport concate


cdef Str to_str(byte_or_string):
    if isinstance(byte_or_string, str):
        return Str(byte_or_string.encode("utf8", "replace"))
    else:
        return Str(bytes(byte_or_string))


def cypxml_to_py_str(xml):
    return xml.to_bytes().decode("utf-8")
