# distutils: language = c++

from libcythonplus.list cimport cyplist

from libc.stdio cimport fprintf, fopen, fclose, fread, fwrite, FILE, stdout, printf, ferror

from runtime.runtime cimport SequentialMailBox, BatchMailBox, NullResult, Scheduler

from stdlib.stat cimport Stat, dev_t
from stdlib.digest cimport MessageDigest, md5sum, sha1sum, sha256sum, sha512sum
from stdlib.fmt cimport sprintf
from stdlib.string cimport string
from stdlib.dirent cimport DIR, struct_dirent, opendir, readdir, closedir

from posix.unistd cimport readlink


cdef lock Scheduler scheduler


cdef cypclass Node activable:
    string path
    string name
    Stat st
    string formatted

    __init__(self, string path, string name, Stat st):
        self._active_result_class = NullResult
        self._active_queue_class = consume BatchMailBox(scheduler)
        self.path = path
        self.name = name
        self.st = st

    void build_node(self, lock cyplist[dev_t] dev_whitelist, lock cyplist[string] ignore_paths):
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


cdef iso Node make_node(string path, string name) nogil:
    s = Stat(path)
    if s is NULL:
        return NULL
    elif s.is_symlink():
        return consume SymlinkNode(path, name, consume s)
    elif s.is_dir():
        return consume DirNode(path, name, consume s)
    elif s.is_regular():
        return consume FileNode(path, name, consume s)
    return NULL


cdef cypclass DirNode(Node):
    cyplist[active Node] children

    __init__(self, string path, string name, Stat st):
        Node.__init__(self, path, name, st)
        self.children = new cyplist[active Node]()
        self.children.__init__()

    void build_node(self, lock cyplist[dev_t] dev_whitelist, lock cyplist[string] ignore_paths):
        cdef DIR *d
        cdef struct_dirent *entry
        cdef string entry_name
        cdef string entry_path

        if ignore_paths is not NULL:
            if self.path in ignore_paths:
                return

        if dev_whitelist is not NULL:
            if self.st is NULL:
                return
            elif not self.st.st_data.st_dev in dev_whitelist:
                return

        d = opendir(self.path.c_str())
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
            active_child.build_node(NULL, dev_whitelist, ignore_paths)

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
    string md5_data
    string sha1_data
    string sha256_data
    string sha512_data
    bint error

    __init__(self, string path, string name, Stat st):
        Node.__init__(self, path, name, st)
        self.error = False

    void build_node(self, lock cyplist[dev_t] dev_whitelist, lock cyplist[string] ignore_paths):
        cdef unsigned char buffer[BUFSIZE]
        cdef bint eof = False
        cdef bint md5_ok
        cdef bint sha1_ok
        cdef bint sha256_ok
        cdef bint sha512_ok

        cdef FILE * file = fopen(self.path.c_str(), 'rb')

        if file is NULL:
            self.error = True
            self.format_node()
            return

        md5 = MessageDigest(md5sum())
        sha1 = MessageDigest(sha1sum())
        sha256 = MessageDigest(sha256sum())
        sha512 = MessageDigest(sha512sum())

        md5_ok = md5 is not NULL
        sha1_ok = sha1 is not NULL
        sha256_ok = sha256 is not NULL
        sha512_ok = sha512 is not NULL

        while not eof and (md5_ok or sha1_ok or sha256_ok or sha512_ok):
            size = fread(buffer, 1, BUFSIZE, file)
            if size != BUFSIZE:
                self.error = ferror(file)
                if self.error:
                    break
                eof = True

            if md5_ok: md5_ok = md5.update(buffer, size) == 0
            if sha1_ok: sha1_ok = sha1.update(buffer, size) == 0
            if sha256_ok: sha256_ok = sha256.update(buffer, size) == 0
            if sha512_ok: sha512_ok = sha512.update(buffer, size) == 0

        fclose(file)

        if not self.error:
            if md5_ok: self.md5_data = md5.hexdigest()
            if sha1_ok: self.sha1_data = sha1.hexdigest()
            if sha256_ok: self.sha256_data = sha256.hexdigest()
            if sha512_ok: self.sha512_data = sha512.hexdigest()

        self.format_node()

    void format_node(self):
        if self.error:
            Node.format_node(self)
        else:
            self.formatted = sprintf("""\
  {
    "%s": {
      "stat": %s,
      "digests": {
        "md5": "%s",
        "sha1": "%s",
        "sha256": "%s",
        "sha512": "%s"
      }
    }
  },
""",
                self.path,
                self.st.to_json(),
                self.md5_data,
                self.sha1_data,
                self.sha256_data,
                self.sha512_data,
            )

    void write_node(self, FILE * stream):
        fwrite(self.formatted.data(), 1, self.formatted.size(), stream)


cdef cypclass SymlinkNode(Node):
    string target
    int error

    void build_node(self, lock cyplist[dev_t] dev_whitelist, lock cyplist[string] ignore_paths):
        size = self.st.st_data.st_size + 1
        self.target.resize(size)
        real_size = readlink(self.path.c_str(), <char*> self.target.data(), size)
        self.error = not (0 < real_size < size)
        self.target.resize(real_size)
        self.format_node()

    void format_node(self):
        if self.error:
            Node.format_node(self)
        else:
            self.formatted = sprintf("""\
  {
    "%s": {
      "stat": %s,
      "target": "%s"
    }
  },
""",
            self.path,
            self.st.to_json(),
            self.target,
        )

    void write_node(self, FILE * stream):
        fwrite(self.formatted.data(), 1, self.formatted.size(), stream)


cdef int start(string path) nogil:
    global scheduler
    scheduler = Scheduler()

    ignore_paths = cyplist[string]()
    ignore_paths.append(b'/opt/slapgrid')
    ignore_paths.append(b'/srv/slapgrid')

    dev_whitelist_paths = cyplist[string]()
    dev_whitelist_paths.append(b'.')
    dev_whitelist_paths.append(b'/')
    dev_whitelist_paths.append(b'/boot')

    dev_whitelist = cyplist[dev_t]()
    for p in dev_whitelist_paths:
        p_stat = Stat(p)
        if p_stat is not NULL:
            p_dev = p_stat.st_data.st_dev
            dev_whitelist.append(p_dev)

    node = make_node(path, path)
    if node is NULL:
        return -1

    active_node = activate(consume node)

    active_node.build_node(NULL, consume dev_whitelist, consume ignore_paths)

    scheduler.finish()

    node = consume active_node

    result = fopen('result.json', 'w')
    if result is NULL:
        return -1

    fprintf(result, '[\n')
    node.write_node(result)
    fprintf(result, '  {}\n]\n')

    fclose(result)

    del scheduler

    return 0

cdef public int main() nogil:
    return start(<char*>'.')

def python_main():
    start(<char*>'.')
