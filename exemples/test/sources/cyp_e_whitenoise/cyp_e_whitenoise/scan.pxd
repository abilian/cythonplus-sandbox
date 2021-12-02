# distutils: language = c++
from libc.stdio cimport (printf, puts, fprintf, fopen, fclose, fread,
                         fwrite, FILE, stdout, ferror)
from posix.unistd cimport readlink

from libcythonplus.list cimport cyplist
from libcythonplus.dict cimport cypdict

from scheduler.scheduler cimport BatchMailBox, NullResult, Scheduler
# from scheduler.scheduler cimport SequentialMailBox, NullResult, Scheduler

from stdlib._string cimport string
from stdlib.string cimport Str
from stdlib.format cimport format

from stdlib.stat cimport Stat, dev_t
from stdlib.dirent cimport DIR, struct_dirent, opendir, readdir, closedir
from stdlib.intlist cimport Intlist

# Use global for scheduler:
cdef lock Scheduler scheduler

# ctypedef cypdict[string, Intlist] Fdict

cdef cyplist[string] collector
cdef Fdict collector2

cdef cypclass Fdict:
    cypdict[string, Intlist] dic

    __init__(self):
        self.dic = cypdict[string, Intlist]()


cdef cypclass Node activable:
    iso Str path
    iso Str name
    Stat st
    string path_key
    int stat_size
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
        pass

    void collect(self):
        # collector2[self.path._str] = Intlist()
        if self.kind == 2:
            while self.children.__len__() > 0:
                active_child = self.children[self.children.__len__() -1]
                del self.children[self.children.__len__() -1]
                child = consume active_child
                child.collect()



cdef iso Node make_node(iso Str, iso Str) nogil
# cdef Fdict scan_fs_dic(Str) nogil
cdef void scan_fs_dic(Str) nogil
cdef Str to_str(s)
cdef from_str(Str s)
