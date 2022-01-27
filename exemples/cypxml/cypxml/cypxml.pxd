from stdlib.string cimport Str
from stdlib._string cimport string
from stdlib.format cimport format
from libcythonplus.dict cimport cypdict
from libcythonplus.list cimport cyplist

from .stdlib.xml_utils cimport replace_one, replace_all
from .stdlib.xml_utils cimport escaped
from .stdlib.xml_utils cimport quoteattr, nameprep
from .stdlib.xml_utils cimport concate


cdef cypclass cypXML:
    """A cypclass providing basic XML document API
    """
    Str encoding
    Str indent
    int indentation
    bint newline
    cypElement open_tag
    cyplist[Str] chunks  # a list of strings

    __init__(self, Str version):
        self.encoding = Str("utf-8")
        self.indent = Str("  ")
        self.indentation = 0
        self.newline = 0
        self.open_tag = NULL
        self.chunks = cyplist[Str]()
        self._set_version(version)

    void _append_indent(self):
        if self.indentation > 0:
            for _i in range(self.indentation):
                self.chunks.append(self.indent)

    void _append_newline(self):
        if self.newline:
            self.chunks.append(Str("\n"))

    void _set_version(self, Str version):
        if version is not NULL:
            self.write(format(
                "<?xml version=\"{}\" encoding=\"{}\"?>",
                version,
                self.encoding
            ))

    void write(self, Str content):
        """Write raw content to the document"""
        self.chunks.append(content)
        self.newline = 1

    void write_escaped(self, Str content):
        """Write escaped content to the document"""
        self.write(escaped(content, NULL))

    void write_indented(self, Str content):
        """Write indented content to the document"""
        self._append_newline()
        self._append_indent()
        self.chunks.append(content)

    Str to_str(self):
        return concate(self.chunks)

    const char * to_bytes(self):
        return self.to_str()._str.c_str()


cdef cypclass cypElement:
    """A cypclass providing basic XML element API
    """
    Str name

    __init__(self, Str name):
        self.name = nameprep(name)


cdef Str to_str(byte_or_string)
