from stdlib.string cimport Str
from stdlib.format cimport format
from libcythonplus.dict cimport cypdict
from libcythonplus.list cimport cyplist

from .stdlib.xml_utils cimport escaped, quotedattr, nameprep, concate

from libc.stdio cimport *

from .cypxml cimport cypXML

from os.path import abspath, dirname, join


base_path = abspath(dirname(__file__))


cdef Str read_file(Str path) nogil:
    cdef FILE * file
    cdef cyplist[Str] str_buffer
    cdef char buffer[8192]
    cdef bint eof = False
    cdef int size

    str_buffer = cyplist[Str]()
    file = fopen(path._str.c_str(), "rb")
    if file is NULL:
        with gil:
            raise RuntimeError("file not found %s" % path.bytes())
    while not eof:
        size = fread(buffer, 1, 8192, file)
        if size != 8192:
            if ferror(file):
                with gil:
                    raise RuntimeError("file read error %s" % path.bytes())
            eof = True
        if size == 8192:
            str_buffer.append(Str(buffer))
        else:
            str_buffer.append(Str(buffer).substr(0, size))
    fclose(file)
    result = concate(str_buffer)
    return result

cdef Str test_content(name):
    cdef Str path

    path = Str(join(base_path, "expected", name).encode("utf8"))
    return read_file(path)

##############################################################################

cdef bint test_min():
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

cdef bint test_version():
    cdef cypXML xml
    cdef Str expected
    cdef Str result

    xml = cypXML()
    xml.init_version(Str("1.0"))

    expected = Str("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n")
    result = xml.dump()
    if result == expected:
        return 1
    print("-------------------------------------")
    print(result.bytes())
    raise RuntimeError()

cdef bint test_1_tag():
    cdef cypXML xml
    cdef Str expected
    cdef Str result

    xml = cypXML()
    xml.tag(Str("tag"))
    result = xml.dump()

    expected = Str("<tag />\n")
    if result == expected:
        return 1
    print("-------------------------------------")
    print(result.bytes())
    raise RuntimeError()

cdef bint test_2_tag():
    cdef cypXML xml
    cdef Str expected
    cdef Str result

    xml = cypXML()
    xml.tag(Str("tag"))
    xml.tag(Str("tig"))
    result = xml.dump()

    expected = Str("<tag />\n<tig />\n")
    if result == expected:
        return 1
    print("-------------------------------------")
    print(result.bytes())
    raise RuntimeError()

cdef bint test_3_tag():
    cdef cypXML xml
    cdef Str expected
    cdef Str result

    xml = cypXML()
    xml.tag(Str("tag"))
    xml.tag(Str("tig"))
    xml.tag(Str("tag"))
    result = xml.dump()

    expected = Str("<tag />\n<tig />\n<tag />\n")
    if result == expected:
        return 1
    print("-------------------------------------")
    print(result.bytes())
    raise RuntimeError()

cdef bint test_1_tag_text():
    cdef cypXML xml
    cdef Str expected
    cdef Str result

    xml = cypXML()
    t = xml.tag(Str("tag"))
    t.text(Str("content."))
    result = xml.dump()

    expected = Str("<tag>content.</tag>\n")
    if result == expected:
        return 1
    print("-------------------------------------")
    print(result.bytes())
    raise RuntimeError()

cdef bint test_2_tag_text():
    cdef cypXML xml
    cdef Str expected
    cdef Str result

    xml = cypXML()
    t = xml.tag(Str("tag1"))
    t.text(Str("content1."))
    t = xml.tag(Str("tag2"))
    t.text(Str("content2."))
    result = xml.dump()

    expected = Str("<tag1>content1.</tag1>\n<tag2>content2.</tag2>\n")
    if result == expected:
        return 1
    print("-------------------------------------")
    print(result.bytes())
    print(result.bytes().decode("utf8"))
    raise RuntimeError()

cdef bint test_2_tag_text_mod():
    cdef cypXML xml
    cdef Str expected
    cdef Str result

    xml = cypXML()
    t = xml.tag(Str("tag1"))
    t2 = xml.tag(Str("tag2"))
    t.text(Str("content1."))
    t2.text(Str("content2."))
    result = xml.dump()

    expected = Str("<tag1>content1.</tag1>\n<tag2>content2.</tag2>\n")
    if result == expected:
        return 1
    print("-------------------------------------")
    print(result.bytes())
    print(result.bytes().decode("utf8"))
    raise RuntimeError()

cdef bint test_1_attr():
    cdef cypXML xml
    cdef Str expected
    cdef Str result

    xml = cypXML()
    t = xml.tag(Str("tag"))
    t.attr(Str("key"), Str("value"))
    result = xml.dump()

    expected = Str("<tag key=\"value\" />\n")

    if result == expected:
        return 1
    print("-------------------------------------")
    print(result.bytes())
    print(result.bytes().decode("utf8"))
    raise RuntimeError()

cdef bint test_1_attr_text_to_escape():
    cdef cypXML xml
    cdef Str expected
    cdef Str result

    xml = cypXML()
    t = xml.tag(Str("tag"))
    t.attr(Str("key__aa"), Str("value with & > 4"))
    t.text(Str("text with <>"))
    result = xml.dump()

    expected = Str("<tag key:aa=\"value with &amp; &gt; 4\">text with &lt;&gt;</tag>\n")

    if result == expected:
        return 1
    print("-------------------------------------")
    print(result.bytes())
    print(result.bytes().decode("utf8"))
    raise RuntimeError()

cdef bint test_1_embed():
    cdef cypXML xml
    cdef Str expected
    cdef Str result

    xml = cypXML()
    t1 = xml.tag(Str("tag1"))
    t2 = t1.tag(Str("tag2"))
    t3 = t2.tag(Str("tag3"))
    t32 = t2.tag(Str("tag3bis"))
    result = xml.dump()

    expected = Str("<tag1>\n  <tag2>\n    <tag3 />\n    <tag3bis />\n  </tag2>\n</tag1>\n")

    if result == expected:
        return 1
    print("-------------------------------------")
    print(result.bytes())
    print(result.bytes().decode("utf8"))
    raise RuntimeError()

cdef bint test_1_embed_attr_text():
    cdef cypXML xml
    cdef Str expected
    cdef Str result

    xml = cypXML()
    t1 = xml.tag(Str("tag1"))
    t2 = t1.tag(Str("tag2"))
    t2.attr(Str("key"), Str("value"))
    t3 = t2.tag(Str("tag3"))
    t3.text(Str("description 3"))
    t32 = t2.tag(Str("tag3bis"))
    t32.text(Str("description & 3bis"))
    t32.attr(Str("x"), Str("y"))
    result = xml.dump()

    expected = Str("<tag1>\n  <tag2 key=\"value\">\n    <tag3>description 3</tag3>\n    <tag3bis x=\"y\">description &amp; 3bis</tag3bis>\n  </tag2>\n</tag1>\n")

    if result == expected:
        return 1
    print("-------------------------------------")
    print(result.bytes())
    print(result.bytes().decode("utf8"))
    raise RuntimeError()

##############################################################################

cdef bint test_utf8_document(Str expected):
    cdef cypXML xml
    cdef Str result

    ### code to test

    xml = cypXML()
    xml.init_version(Str("1.0"))
    t = xml.tag(Str("test"))
    d = t.tag(Str("description"))
    d.text(Str("An animated fantasy film from 1978 based on the first half of J.R.R Tolkien’s Lord of the Rings novel. The film was mainly filmed using rotoscoping, meaning it was filmed in live action sequences with real actors and then each frame was individually animated."
    ))
    result = xml.dump()

    ### / code to test

    if result == expected:
        return 1
    print("-------------------------------------")
    print(result.bytes())
    print(result.bytes().decode("utf8"))
    raise RuntimeError()

cdef bint test_simple_document(Str expected):
    cdef cypXML xml
    cdef Str result

    ### code to test

    xml = cypXML()
    xml.init_version(Str("1.0"))
    t = xml.tag(Str("person"))
    t2 = t.tag(Str("name"))
    t2.text(Str("Bob"))
    t2 = t.tag(Str("city"))
    t2.text(Str("Qusqu"))
    result = xml.dump()

    ### / code to test

    if result == expected:
        return 1
    print("----- result:")
    print(result.bytes())
    print("----- result:")
    print(result.bytes().decode("utf8"))
    print("----- expect:")
    print(expected.bytes().decode("utf8"))
    print("-----")
    raise RuntimeError()

cdef bint test_rootless_fragment(Str expected):
    cdef cypXML xml
    cdef Str result

    ### code to test

    xml = cypXML()
    xml.tag(Str("data")).attr(Str("value"), Str("Just some data"))
    result = xml.dump()

    ### / code to test

    if result == expected:
        return 1
    print("----- result:")
    print(result.bytes())
    print("----- result:")
    print(result.bytes().decode("utf8"))
    print("----- expect:")
    print(expected.bytes().decode("utf8"))
    print("-----")
    raise RuntimeError()

cdef bint test_nested_elements(Str expected):
    cdef cypXML xml
    cdef Str result

    ### code to test

    xml = cypXML()
    feed = xml.tag(Str("feed")).attr(Str("xmlns"), Str("http://www.w3.org/2005/Atom"))
    feed.tag(Str("title")).text(Str("Example Feed"))
    feed.tag(Str("updated")).text(Str("2003-12-13T18:30:02Z"))
    a = feed.tag(Str("author"))
    a.tag(Str("name")).text(Str("John Doe"))
    feed.tag(Str("id")).text(Str("urn:uuid:60a76c80-d399-11d9-b93C-0003939e0af6"))
    e = feed.tag(Str("entry"))
    e.tag(Str("title")).text(Str("Atom-Powered Robots Run Amok"))
    e.tag(Str("id")).text(Str("urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a"))
    e.tag(Str("updated")).text(Str("2003-12-13T18:30:02Z"))
    e.tag(Str("summary")).text(Str("Some text."))
    result = xml.dump()

    ### / code to test

    if result == expected:
        return 1
    print("----- result:")
    print(result.bytes())
    print("----- result:")
    print(result.bytes().decode("utf8"))
    print("----- expect:")
    print(expected.bytes().decode("utf8"))
    print("-----")
    raise RuntimeError()

cdef bint test_namespaces(Str expected):
    cdef cypXML xml
    cdef Str result

    ### code to test

    xml = cypXML()
    p = xml.tag(Str("parent")).attr(Str("xmlns:my"), Str("http://example.org/ns/"))
    p.tag(Str("my:child")).attr(Str("my:attr"), Str("foo"))
    result = xml.dump()

    ### / code to test

    if result == expected:
        return 1
    print("----- result:")
    print(result.bytes())
    print("----- result:")
    print(result.bytes().decode("utf8"))
    print("----- expect:")
    print(expected.bytes().decode("utf8"))
    print("-----")
    raise RuntimeError()

cdef bint test_extended_syntax(Str expected):
    cdef cypXML xml
    cdef Str result

    ### code to test

    xml = cypXML()
    xml.set_indent_space(Str("    "))  # change indentation to 4 spaces
    doc = xml.tag(Str("doc"))
    e = doc.tag(Str("elem"))
    e.attr(Str("x"), Str("x")).attr(Str("y"), Str("y")).attr(Str("z"), Str("z"))
    e = doc.tag(Str("elem"))
    e.attr(Str("x"), Str("x")).attr(Str("y"), Str("y")).attr(Str("z"), Str("z"))
    e = doc.tag(Str("elem"))
    # order keep ok:
    e.attr(Str("z"), Str("z")).attr(Str("y"), Str("y")).attr(Str("x"), Str("x"))
    doc.tag(Str("container")).tag(Str("elem"))
    doc.tag(Str("container")).tag(Str("elem"))
    result = xml.dump()

    ### / code to test

    if result == expected:
        return 1
    print("----- result:")
    print(result.bytes())
    print("----- result:")
    print(result.bytes().decode("utf8"))
    print("----- expect:")
    print(expected.bytes().decode("utf8"))
    print("-----")
    raise RuntimeError()

cdef bint test_content_escaping(Str expected):
    cdef cypXML xml
    cdef Str result

    ### code to test

    xml = cypXML()
    doc = xml.tag(Str("doc"))
    i = doc.tag(Str("item")).attr(Str("some_attr"), Str("attribute&value>to<escape"))
    i.text(Str("Text&to<escape"))
    result = xml.dump()

    ### / code to test

    if result == expected:
        return 1
    print("----- result:")
    print(result.bytes())
    print("----- result:")
    print(result.bytes().decode("utf8"))
    print("----- expect:")
    print(expected.bytes().decode("utf8"))
    print("-----")
    raise RuntimeError()

cdef bint test_atom_feed(Str expected):
    cdef cypXML xml
    cdef Str result

    ### code to test

    xml = cypXML()
    xml.init_version(Str("1.0"))
    feed = xml.tag(Str("feed")).attr(Str("xmlns"), Str("http://www.w3.org/2005/Atom"))
    feed.tag(Str("title")).text(Str("Example Feed"))
    feed.tag(Str("link")).attr(Str("href"), Str("http://example.org/"))
    feed.tag(Str("updated")).text(Str("2003-12-13T18:30:02Z"))
    a = feed.tag(Str("author"))
    a.tag(Str("name")).text(Str("John Doe"))
    a.tag(Str("id")).text(Str("urn:uuid:60a76c80-d399-11d9-b93C-0003939e0af6"))
    a.tag(Str("title")).text(Str("Atom-Powered Robots Run Amok"))
    a.tag(Str("link")).attr(Str("href"), Str("http://example.org/2003/12/13/atom03"))
    a.tag(Str("id")).text(Str("urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a"))
    a.tag(Str("updated")).text(Str("2003-12-13T18:30:02Z"))
    a.tag(Str("summary")).text(Str("Some text."))
    c = a.tag(Str("content")).attr(Str("type"), Str("xhtml"))
    d = c.tag(Str("div")).attr(Str("xmlns"), Str("http://www.w3.org/1999/xhtml"))
    d.tag(Str("label")).attr(Str("for"), Str("some_field")).text(Str("Some label"))
    d.tag(Str("input")).attr(Str("type"), Str("text")).attr(Str("value"), Str(""))
    result = xml.dump()

    ### / code to test

    if result == expected:
        return 1
    print("----- result:")
    print(result.bytes())
    print("----- result:")
    print(result.bytes().decode("utf8"))
    print("----- expect:")
    print(expected.bytes().decode("utf8"))
    print("-----")
    raise RuntimeError()

##############################################################################


def main():
    print("-------------------------------------")
    print("Test cypxml")
    test_min()
    test_version()
    test_1_tag()
    test_2_tag()
    test_3_tag()
    test_1_tag_text()
    test_2_tag_text()
    test_2_tag_text_mod()
    test_1_attr()
    test_1_attr_text_to_escape()
    test_1_embed()
    test_1_embed_attr_text()
    test_utf8_document(test_content("utf8_document.xml"))
    test_simple_document(test_content("simple_document.xml"))
    test_rootless_fragment(test_content("rootless_fragment.xml"))
    test_nested_elements(test_content("nested_elements.xml"))
    test_namespaces(test_content("namespaces.xml"))
    test_extended_syntax(test_content("extended_syntax.xml"))
    test_content_escaping(test_content("content_escaping.xml"))
    test_atom_feed(test_content("atom_feed.xml"))
    print("Done.")
