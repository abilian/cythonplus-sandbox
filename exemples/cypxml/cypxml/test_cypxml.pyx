from stdlib.string cimport Str
from stdlib.format cimport format
from libcythonplus.dict cimport cypdict
from libcythonplus.list cimport cyplist

from .stdlib.xml_utils cimport escaped, quotedattr, nameprep, concate


from .cypxml cimport cypXML

cdef bint test_cypxml_min():
    cdef cypXML xml
    cdef Str expected
    cdef Str result

    xml = cypXML()
    expected = Str("")
    result = xml.dump()
    if result == expected:
        return 1
    print("-------------------------------------")
    print(result.bytes())
    raise RuntimeError()

cdef bint test_cypxml_version():
    cdef cypXML xml
    cdef Str expected
    cdef Str result

    xml = cypXML()
    xml.init_version(Str("1.0"))

    expected = Str("<?xml version=\"{}\" encoding=\"utf-8\"?>\n")
    result = xml.dump()
    if result == expected:
        return 1
    print("-------------------------------------")
    print(result.bytes())
    raise RuntimeError()

##############################################################################

def main():
    print("-------------------------------------")
    print("Test cypxml")
    test_cypxml_min
    test_cypxml_version
    print("Done.")
