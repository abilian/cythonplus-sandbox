# distutils: language = c++
from posix.types cimport off_t, time_t
# from libc.stdio cimport (printf, puts, fprintf, fopen, fclose, fread,
#                          fwrite, FILE, stdout, ferror)
from libc.stdio cimport puts
from libcythonplus.list cimport cyplist
from stdlib.string cimport Str
from stdlib._string cimport string

from stdlib.stat cimport Stat
from stdlib.dirent cimport DIR, struct_dirent, opendir, readdir, closedir
# from scheduler.scheduler cimport BatchMailBox, NullResult, Scheduler
from scheduler.scheduler cimport SequentialMailBox, NullResult, Scheduler

from .common cimport Finfo, Fdict


cdef iso Node make_node(iso Str path, iso Str name) nogil:
    # with gil:
    #     print(path.bytes(), name.bytes())
    s = Stat(path._str.c_str())
    if s is NULL:
        return NULL
    if s.is_regular() or s.is_dir():
        return consume Node(consume path, consume name, consume s)
    return NULL



cdef Fdict scan_fs_dic(Str path) nogil:
    cdef iso Node node
    cdef Str root_path, path1, path2
    global scheduler
    scheduler = Scheduler()
    global collector
    collector = Fdict()

    # root_path = Str("/home/jd/bin")
    # path1 = root_path.copy()
    # path2 = root_path.copy()
    path1 = path.copy()
    path2 = path.copy()
    node = make_node(consume path1, consume path2)
    if node is not NULL:
        active_node = activate(consume node)
        active_node.build_node(NULL)
        scheduler.finish()
        node = consume active_node
        node.collect()

    del scheduler
    return collector
