from stdlib.string cimport Str
from stdlib.format cimport format
from libcythonplus.dict cimport cypdict
from libcythonplus.list cimport cyplist

from .stdlib.xml_utils cimport escaped, quotedattr, nameprep, concate


cdef cypclass cypXML:
    """A basic cypclass providing XML document API
    """
    Str version
    # cypElement root
    cyplist[cypElement] children
    cyplist[Str] chunks

    __init__(self):
        self.version = Str()
        # self.root = cypElement(Str(""))
        self.children = cyplist[cypElement]()
        self.chunks = NULL

    void init_version(self, Str version):
        self.version = version

    Str _generate_header(self):
        cdef Str header

        if self.version.__len__() == 0:
            header = Str()
        else:
            header = format(
                "<?xml version=\"{}\" encoding=\"utf-8\"?>\n",
                self.version
            )
        return header

    cypElement tag(self, Str name):
        cdef cypElement e

        e = cypElement(name)
        self.children.append(e)
        return e

    Str dump(self):
        cdef Str result
        cdef cypElement c

        self.chunks = cyplist[Str]()
        self.chunks.append(_generate_header())
        for c in self.children:
            self.chunks.append(c.dump(0))
        result = concate(self.chunks)
        return result

    const char * to_bytes(self):
        return self.dump()._str.c_str()


cdef cypclass cypElement:
    """A basic cypclass providing XML tag definition
    """
    Str name
    # cypElement parent  unused
    cyplist[cypElement] children
    cyplist[Str] attributes
    cyplist[Str] content

    __init__(self, Str name):
    # __init__(self, Str name, cypElement parent):
        self.name = nameprep(name)
        # self.parent = parent
        self.children = cyplist[cypElement]()
        self.attributes = cyplist[Str]()
        self.content = cyplist[Str]()

    Str _space_indent(self, int indent):
        # need cache and recurse
        cdef Str space
        cdef Str result
        cdef cyplist[Str] sp_indent

        space = Str("  ")  # 2 spaces
        sp_indent = cyplist[Str]()
        if indent > 0:
            for _i in range(indent):
                sp_indent.append(space)
            result = concate(sp_indent)
        else:
            result = Str("")
        return result

    Str dump(self, int indent):
        cdef Str spaces
        cdef cypElement c
        cdef cyplist[Str] child_dump
        cdef Str result

        spaces = self._space_indent(indent)
        if self.children.__len__() > 0:
            child_dump = cyplist[Str]()
            for c in self.children:
                child_dump.append(c.dump(indent + 1))
            if self.attributes.__len__() > 0:
                result = format(
                    "{}<{}{}>\n{}{}</{}>\n",
                    spaces,
                    self.name,
                    concate(self.attributes),
                    concate(child_dump),
                    spaces,
                    self.name,
                )
            else:
                result = format(
                    "{}<{}>\n{}{}</{}>\n",
                    spaces,
                    self.name,
                    concate(child_dump),
                    spaces,
                    self.name,
                )
        else:
            if self.attributes.__len__() > 0:
                result = format(
                    "{}<{}{} />\n",
                    spaces,
                    self.name,
                    concate(self.attributes)
                )
            else:
                result = format(
                    "{}<{} />\n",
                    spaces,
                    self.name
                )
        return result

    cypElement tag(self, Str name):
        cdef cypElement e

        e = cypElement(name)
        self.children.append(e)
        return e

    void text(self, Str txt):
        self.content.append(escaped(txt, NULL))

    void attrib(self, Str key, Str value):
        self.attributes.append(format(
            " {}={}",
            nameprep(key),
            quotedattr(value, NULL)
        ))


cdef Str to_str(byte_or_string)
