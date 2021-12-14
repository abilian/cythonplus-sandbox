# distutils: language = c++
from libc.stdio cimport (printf, puts, fprintf, fopen, fclose, fread,
                         fwrite, FILE, stdout, ferror)
# from posix.unistd cimport readlink

from scheduler.scheduler cimport BatchMailBox, NullResult, Scheduler
# from scheduler.scheduler cimport SequentialMailBox, NullResult, Scheduler

from stdlib._string cimport string
from stdlib.string cimport Str

from stdlib.stat cimport Stat
from stdlib.dirent cimport DIR, struct_dirent, opendir, readdir, closedir


cdef iso Node make_node(iso Str path, iso Str name) nogil:
    s = Stat(path.bytes())
    if s is NULL:
        return NULL
    if s.is_regular() or s.is_dir():
        return consume Node(consume path, consume name, consume s)
    return NULL


cdef Fdict scan_fs_dic(Str path) nogil:
    cdef iso Node node
    global scheduler
    scheduler = Scheduler()
    global collector
    collector = Fdict()

    path2 = path.copy()
    node = make_node(consume path, consume path2)
    if node is not NULL:
        active_node = activate(consume node)
        active_node.build_node(NULL)
        scheduler.finish()
        node = consume active_node
        node.collect()

    del scheduler
    return collector


cdef Str to_str(str s):
    return Str(s.encode("utf8"))


cdef from_str(Str s):
    return s.bytes().decode("utf8", 'replace')


cdef string py_to_string(str s):
    return Str(s.encode("utf8"))._str


cdef string_to_py(string s):
    return s.c_str().decode("utf8", 'replace')
