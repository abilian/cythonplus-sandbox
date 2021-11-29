# distutils: language = c++
from libc.stdio cimport fprintf, fopen, fclose, fread, fwrite, FILE, stdout, printf, ferror, sprintf
from posix.unistd cimport readlink

from libcythonplus.list cimport cyplist

from scheduler.scheduler cimport BatchMailBox, NullResult, Scheduler

from stdlib.stat cimport Stat, dev_t
from stdlib.digest cimport MessageDigest, md5sum, sha1sum, sha256sum, sha512sum
from stdlib.string cimport Str
from stdlib.dirent cimport DIR, struct_dirent, opendir, readdir, closedir


ctypedef StrList StrList

# Use global for scheduler:
cdef lock Scheduler scheduler


cdef cypclass Node activable:
    Str path
    Str name
    Stat st
    Str formatted

    __init__(self, Str path, Str name, Stat st):
        self._active_result_class = NullResult
        self._active_queue_class = consume BatchMailBox(scheduler)
        self.path = path
        self.name = name
        self.st = st

    void build_node(self):
        # abstract
        pass

    void format_node(self):
        self.formatted = sprintf("""\
  {
    "%s": {
      "stat": %s
    }
  },
""",
            self.path,
            self.st.to_json(),
        )

    void write_node(self, FILE * stream):
        # abstract
        pass


cdef iso Node make_node(Str path, Str name) nogil:
    s = Stat(path)
    if s is NULL:
        return NULL
    elif s.is_regular():
        return consume FileNode(path, name, consume s)
    elif s.is_dir():
        return consume DirNode(path, name, consume s)
    return NULL


cdef cypclass DirNode(Node):
    cyplist[active Node] children

    __init__(self, Str path, Str name, Stat st):
        Node.__init__(self, path, name, st)
        self.children = new cyplist[active Node]()
        self.children.__init__()

    void build_node(self):
        cdef DIR *d
        cdef struct_dirent *entry
        cdef Str entry_name
        cdef Str entry_path

        d = opendir(Str.to_c_str(self.path))
        if d is not NULL:
            while 1:
                entry = readdir(d)
                if entry is NULL:
                    break
                entry_name = entry.d_name
                if entry_name == b'.' or entry_name == b'..':
                    continue
                entry_path = self.path
                if entry_path != b'/':
                    entry_path += b'/'
                entry_path += entry_name
                entry_node = make_node(entry_path, entry_name)
                if entry_node is NULL:
                    continue
                active_entry = activate(consume entry_node)
                self.children.append(active_entry)
            closedir(d)

        self.format_node()

        for active_child in self.children:
            active_child.build_node(NULL)

    void write_node(self, FILE * stream):
        fwrite(self.formatted.data(), 1, self.formatted.size(), stream)
        while self.children.__len__() > 0:
            active_child = self.children[self.children.__len__() -1]
            del self.children[self.children.__len__() -1]
            child = consume active_child
            child.write_node(stream)


cdef enum:
    BUFSIZE = 64 * 1024


cdef cypclass FileNode(Node):
    bint error

    __init__(self, Str path, Str name, Stat st):
        Node.__init__(self, path, name, st)
        self.error = False

    void build_node(self):
        cdef unsigned char buffer[BUFSIZE]
        cdef bint eof = False

        self.format_node()

    void format_node(self):
        if self.error:
            Node.format_node(self)
        else:
            self.formatted = sprintf("""\
  {
    "%s": {
      "stat": %s,
    }
  },
""",
                self.path,
                self.st.to_json(),
            )

    void write_node(self, FILE * stream):
        fwrite(self.formatted.data(), 1, self.formatted.size(), stream)



cdef Str scan_fs(Str path) nogil:
    global scheduler
    scheduler = Scheduler()

    node = make_node(path, path)
    if node is NULL:
        return NULL

    active_node = activate(consume node)
    active_node.build_node(NULL)
    scheduler.finish()
    node = consume active_node

    result = fopen('result.json', 'w')
    if result is NULL:
        return NULL

    fprintf(result, '[\n')
    node.write_node(result)
    fprintf(result, '  {}\n]\n')

    fclose(result)

    del scheduler

    return "result"



cdef decoded(Str s):
    return s._str.data().decode("utf8", 'replace')


def python_scan_fs(path=None):
    if path is None:
        path = '.'
    return decoded(scan_fs(Str(path)))
