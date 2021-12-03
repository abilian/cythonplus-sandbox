# distutils: language = c++
from posix.types cimport off_t, time_t
from libc.stdio cimport (printf, puts, fprintf, fopen, fclose, fread,
                         fwrite, FILE, stdout, ferror)
# from posix.unistd cimport readlink

from libcythonplus.list cimport cyplist
from libcythonplus.dict cimport cypdict

from scheduler.scheduler cimport BatchMailBox, NullResult, Scheduler
# from scheduler.scheduler cimport SequentialMailBox, NullResult, Scheduler

from stdlib._string cimport string
from stdlib.string cimport Str

from stdlib.stat cimport Stat
from stdlib.dirent cimport DIR, struct_dirent, opendir, readdir, closedir


ctypedef cypdict[string, Finfo] Fdict

# Use global for scheduler and collector:
cdef lock Scheduler scheduler
cdef Fdict collector


cdef cypclass Finfo:
    # bint is_reg
    # bint is_dir
    off_t size
    time_t mtime

    __init__(self, off_t size, time_t mtime):
        # self.is_reg = is_reg
        # self.is_dir = is_dir
        self.size = size
        self.mtime = mtime


cdef cypclass Node activable:
    iso Str path
    iso Str name
    bint is_reg
    bint is_dir
    off_t size
    time_t mtime
    cyplist[active Node] children

    __init__(self, iso Str path, iso Str name, Stat st):
        self._active_result_class = NullResult
        self._active_queue_class = consume BatchMailBox(scheduler)
        # self._active_queue_class = consume SequentialMailBox(scheduler)
        self.path = consume path
        self.name = consume name
        self.size = st.st_data.st_size
        self.mtime = st.st_data.st_mtim.tv_sec
        self.is_reg = st.is_regular()
        self.is_dir = st.is_dir()
        if self.is_dir:
            self.children = new cyplist[active Node]()
            self.children.__init__()

    void build_node(self):
        if self.is_dir:
            self.build_node_dir()

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
        for active_child in self.children:
            active_child.build_node(NULL)

    void collect(self):
        "Collect size and mtime for regular files"
        if self.is_reg:
            collector[self.path._str] = Finfo(self.size, self.mtime)
        else:
            while self.children.__len__() > 0:
                active_child = self.children[self.children.__len__() -1]
                del self.children[self.children.__len__() -1]
                child = consume active_child
                child.collect()


cdef iso Node make_node(iso Str, iso Str) nogil
cdef Fdict scan_fs_dic(Str) nogil
cdef Str to_str(str)
cdef from_str(Str)
cdef string py_to_string(str)
cdef string_to_py(string)
