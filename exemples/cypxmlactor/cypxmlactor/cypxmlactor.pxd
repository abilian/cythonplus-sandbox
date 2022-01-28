from stdlib.string cimport Str
from stdlib.format cimport format
from libcythonplus.dict cimport cypdict
from libcythonplus.list cimport cyplist

from .stdlib.xml_utils cimport escaped, quotedattr, nameprep, concate

from scheduler.scheduler cimport SequentialMailBox, NullResult, Scheduler

cdef cypclass cypXMLActor:
    """A basic cypclass providing XML document API
    """
    int nb_workers
    Str version
    cyplist[cypElement] children
    cyplist[Str] content
    Str indent_space
    cyplist[Str] chunks

    __init__(self):
        self.nb_workers = 0  # 0 => will use the detected nb of CPU
        self.version = Str()
        # self.root = cypElement(Str(""))
        self.children = cyplist[cypElement]()
        self.content = cyplist[Str]()
        self.indent_space = Str("  ")
        self.chunks = NULL

    void set_workers(self, int nb):
        self.nb_workers = nb

    void init_version(self, Str version):
        self.version = version

    void init_content(self, Str content):
        self.version = version

    void set_indent_space(self, Str indent_space):
        self.indent_space = indent_space

    void _generate_header(self):
        cdef Str header

        if self.version.__len__() != 0:
            header = format(
                "<?xml version=\"{}\" encoding=\"utf-8\"?>\n",
                self.version
            )
            self.content.insert(0, header)

    cypElement tag(self, Str name):
        cdef cypElement e

        e = cypElement(name, self.indent_space)
        self.children.append(e)
        return e

    Str dump(self):
        cdef Str result
        cdef Str item
        cdef cypElement c
        cdef lock Scheduler scheduler

        self._generate_header()
        self.chunks = cyplist[Str]()
        for item in self.content:
            self.chunks.append(item)

        scheduler = Scheduler(self.nb_workers)
        generator = activate(consume DumpRoot(
                                        scheduler,
                                        consume self.children
                                        )
            )
        generator.run(NULL)
        scheduler.finish()
        del scheduler
        consumed = consume(generator)
        self.chunks.append(<Str> consumed.result())
        result = concate(self.chunks)
        return result

    const char * to_bytes(self):
        return self.dump()._str.c_str()


cdef cypclass DumpRoot activable:
    lock Scheduler scheduler
    active Recorder recorder
    cyplist[cypElement] children
    int size

    __init__(self, lock Scheduler scheduler, iso cyplist[cypElement] children):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.scheduler = scheduler  # keep it for use with sub objects
        self.recorder = activate (consume Recorder(scheduler))
        self.children = children
        self.size = children.__len__()

    void run(self):
        cdef int index

        index = 0
        for child in self.children:
            dumper = <active Dumper> activate(consume Dumper(
                                                            self.scheduler,
                                                            self.recorder,
                                                            consume child,
                                                            index,
                                                            0  # indent
                                                            ))
            index += 1

    Str result(self):
        cdef cypdict[int, Str] stored
        cdef cyplist[Str] lst
        cdef int i
        cdef Str resu

        recorder = consume self.recorder  # strange construct ?
        stored = <cypdict[int, Str]> recorder.content()
        lst = cyplist[Str]()
        for i in range(self.size):
            lst.append(stored[i])
        resu = concate(lst)
        return resu


cdef cypclass Recorder activable:
    cypdict[int, Str] storage

    __init__(self, lock Scheduler scheduler):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.storage = cypdict[int, Str]()

    void store(self, int key, Str value):
        self.storage[key] = value

    cypdict[int, Str] content(self):
        return self.storage


cdef cypclass Dumper activable:
    cypdict[int, Str] storage
    cypdict[int, Str] storage
    cyplist[cypElement] children
    lock Scheduler scheduler
    int size

    __init__(
        self,
        lock Scheduler scheduler,
        active Recorder recorder,
        iso cyplist[cypElement] children,
        int index,
        int indent):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.scheduler = scheduler  # keep it for use with sub objects
        self.recorder = activate (consume RootRecorder(scheduler))
        self.children = children
        self.size = children.__len__()

    void run(self):
        cdef int index

        index = 0
        for child in self.children:
            dumper = <active Dumper> activate(consume Dumper(self.scheduler,
                                                             self.recorder,
                                                             consume child,
                                                             index,
                                                             0  # indent
                                                             ))
            index += 1

    Str result(self):
        cdef cypdict[int, Str] stored
        cdef cyplist[Str] lst
        cdef int i
        cdef Str resu

        recorder = consume self.recorder  # strange construct ?
        stored = <cypdict[int, Str]> recorder.content()
        lst = cyplist[Str]()
        for i in range(self.size):
            lst.append(stored[i])
        resu = concate(lst)
        return resu


cdef cypclass cypElement:
    """A basic cypclass providing XML tag definition
    """
    Str name
    # cypElement parent  unused
    cyplist[cypElement] children
    cyplist[Str] attributes
    cyplist[Str] content
    Str indent_space

    __init__(self, Str name, Str indent_space):
    # __init__(self, Str name, cypElement parent):
        self.name = nameprep(name)
        # self.parent = parent
        self.children = cyplist[cypElement]()
        self.attributes = cyplist[Str]()
        self.content = cyplist[Str]()
        self.indent_space = indent_space

    Str _space_indent(self, int indent):
        # need cache and recurse
        cdef Str space
        cdef Str result
        cdef cyplist[Str] sp_indent

        sp_indent = cyplist[Str]()
        if indent > 0:
            for _i in range(indent):
                sp_indent.append(self.indent_space)
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
            if self.content.__len__() > 0:
                if self.attributes.__len__() > 0:
                    result = format(
                        "{}<{}{}>{}{}</{}>\n",
                        spaces,
                        self.name,
                        concate(self.attributes),
                        concate(self.content),
                        concate(child_dump),
                        self.name,
                    )
                else:
                    result = format(
                        "{}<{}>{}{}</{}>\n",
                        spaces,
                        self.name,
                        concate(self.content),
                        concate(child_dump),
                        spaces,
                        self.name,
                    )
            else:
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
            if self.content.__len__() > 0:
                if self.attributes.__len__() > 0:
                    result = format(
                        "{}<{}{}>{}</{}>\n",
                        spaces,
                        self.name,
                        concate(self.attributes),
                        concate(self.content),
                        self.name,
                    )
                else:
                    result = format(
                        "{}<{}>{}</{}>\n",
                        spaces,
                        self.name,
                        concate(self.content),
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
        """Append an element as child of current element

        Return the added element
        """
        cdef cypElement e

        e = cypElement(name, self.indent_space)
        self.children.append(e)
        return e

    cypElement text(self, Str txt):
        """Append an text as content of current element

        Return the element (self, not the added text)
        """
        self.content.append(escaped(txt, NULL))
        return self

    cypElement attr(self, Str key, Str value):
        """Append an attribute to current element

        Return the element (self, not the added attribute)
        """
        self.attributes.append(format(
            " {}={}",
            nameprep(key),
            quotedattr(value, NULL)
        ))
        return self


cdef Str to_str(byte_or_string)
