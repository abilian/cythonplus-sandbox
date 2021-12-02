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


cdef iso Node make_node(iso Str path, iso Str name) nogil:
    s = Stat(path.bytes())
    if s is NULL:
        return NULL
    elif s.is_regular():
        return consume Node(consume path, consume name, 1, consume s)
    elif s.is_dir():
        return consume Node(consume path, consume name, 2, consume s)
    return NULL


cdef void scan_fs_dic(Str path) nogil:
    global scheduler
    scheduler = Scheduler()
    global collector2
    collector2 = Fdict()

    path2 = path.copy()
    node = make_node(consume path, consume path2)
    if node is NULL:
        # return Fdict()
        return

    active_node = activate(consume node)
    active_node.build_node(NULL)

    scheduler.finish()
    node = consume active_node
    node.collect()

    del scheduler
    return
    # return collector2


cdef Str to_str(s):
    return Str(s.encode("utf8"))


cdef from_str(Str s):
    return s.bytes().decode("utf8", 'replace')
