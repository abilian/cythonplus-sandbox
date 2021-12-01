# distutils: language = c++
from libc.stdio cimport (printf, puts, fprintf, fopen, fclose, fread,
                         fwrite, FILE, stdout, ferror)
from posix.unistd cimport readlink

from libcythonplus.list cimport cyplist

from scheduler.scheduler cimport BatchMailBox, NullResult, Scheduler
# from scheduler.scheduler cimport SequentialMailBox, NullResult, Scheduler

from stdlib.string cimport Str
from stdlib.format cimport format

from stdlib.stat cimport Stat, dev_t
from stdlib.dirent cimport DIR, struct_dirent, opendir, readdir, closedir


# Use global for scheduler:
cdef lock Scheduler scheduler


cdef cypclass Node activable:
    iso Str path
    iso Str name
    Stat st
    Str formatted
    int kind
    cyplist[active Node] children

    __init__(self, iso Str path, iso Str name, int kind, Stat st):
        self._active_result_class = NullResult
        self._active_queue_class = consume BatchMailBox(scheduler)
        # self._active_queue_class = consume SequentialMailBox(scheduler)
        self.path = consume path
        self.name = consume name
        self.st = st
        self.kind = kind
        if self.kind == 2:  # DirNode
            self.children = new cyplist[active Node]()
            self.children.__init__()

    void build_node(self):
        if self.kind == 1:
            self.build_node_file()
        if self.kind == 2:
            self.build_node_dir()

    void build_node_file(self):
        self.format_node()

    void build_node_dir(self):
        cdef DIR *d
        cdef struct_dirent *entry
        cdef Str entry_name
        cdef Str entry_path

        d = opendir(self.path.bytes())
        if d is not NULL:
            while 1:
                entry = readdir(d)
                if entry is NULL:
                    break
                entry_name = Str(<const char *> entry.d_name)
                if entry_name == Str('.') or entry_name == Str('..'):
                    continue
                entry_path = Str(<const char *> self.path.bytes())
                if entry_path != Str('/'):
                    entry_path = entry_path + Str('/')
                entry_path = entry_path + entry_name
                entry_node = make_node(consume entry_path, consume entry_name)
                if entry_node is NULL:
                    continue
                active_entry = activate(consume entry_node)
                self.children.append(active_entry)
            closedir(d)

        self.format_node()
        for active_child in self.children:
            active_child.build_node(NULL)

    void format_node(self):
        self.formatted = format(
             "  {{\n    \"{}\": {{\n    \"stat\": {}\n    }}\n  }},\n",
             consume self.path,
             consume self.st.to_json(),
        )

    void write_node(self, FILE * stream):
        if self.kind == 1:
            self.write_node_file(stream)
        if self.kind == 2:
            self.write_node_dir(stream)

    void write_node_file(self, FILE * stream):
        fwrite(self.formatted.bytes(), 1, self.formatted._str.size(), stream)

    void write_node_dir(self, FILE * stream):
        fwrite(self.formatted._str.data(), 1, self.formatted._str.size(), stream)
        while self.children.__len__() > 0:
            active_child = self.children[self.children.__len__() -1]
            del self.children[self.children.__len__() -1]
            child = consume active_child
            child.write_node(stream)


cdef iso Node make_node(iso Str path, iso Str name) nogil:
    s = Stat(path.bytes())
    if s is NULL:
        return NULL
    elif s.is_regular():
        return consume Node(consume path, consume name, 1, consume s)
    elif s.is_dir():
        return consume Node(consume path, consume name, 2, consume s)
    return NULL


cdef int scan_fs(Str path) nogil:
    global scheduler
    scheduler = Scheduler()

    path2 = path.copy()
    node = make_node(consume path, consume path2)
    if node is NULL:
        return 1

    active_node = activate(consume node)
    active_node.build_node(NULL)

    scheduler.finish()
    node = consume active_node
    result = fopen('result.json', 'w')
    if result is NULL:
        return 2

    fprintf(result, '[\n')
    node.write_node(result)
    fprintf(result, '\n]\n')
    fclose(result)

    del scheduler
    return 0


cdef Str to_str(s):
    return Str(s.encode("utf8"))


cdef from_str(Str s):
    return s.bytes().decode("utf8", 'replace')


def python_scan_fs(path=None):
    if path is None:
        path = '.'
    scan_result = scan_fs(to_str(path))
    if scan_result:
        print("Error scan_fs():", scan_result)
