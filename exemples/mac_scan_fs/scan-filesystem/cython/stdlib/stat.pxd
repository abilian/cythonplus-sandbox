# distutils: language = c++

# Differences with posix.stat:
#
# - the declaration for the non-standard field st_birthtime was removed
#   because cypclass wrapping triggers the generation of a conversion
#   function for the stat structure which references this field.
#
# no - the absent declaration in posix.time of struct timespec was added.
#
# no - the declarations for the time_t fields st_atime, st_mtime, st_ctime
#   were replaced by the fields st_atim, st_mtim, st_ctim
#   of type struct timespec.

from stdlib.string cimport string
from stdlib.fmt cimport sprintf

from posix.types cimport (blkcnt_t, blksize_t, dev_t, gid_t, ino_t, mode_t,
                          nlink_t, off_t, time_t, uid_t)



cdef extern from "<sys/stat.h>" nogil:
    cdef struct struct_stat "stat":
        dev_t   st_dev
        ino_t   st_ino
        mode_t  st_mode
        nlink_t st_nlink
        uid_t   st_uid
        gid_t   st_gid
        dev_t   st_rdev
        off_t   st_size
        blksize_t st_blksize
        blkcnt_t st_blocks
        time_t  st_atime
        time_t  st_mtime
        time_t  st_ctime

# POSIX prescribes including both <sys/stat.h> and <unistd.h> for these
cdef extern from "<unistd.h>" nogil:
    int fchmod(int, mode_t)
    int chmod(const char *, mode_t)

    int fstat(int, struct_stat *)
    int lstat(const char *, struct_stat *)
    int stat(const char *, struct_stat *)

    # Macros for st_mode
    mode_t S_ISREG(mode_t)
    mode_t S_ISDIR(mode_t)
    mode_t S_ISCHR(mode_t)
    mode_t S_ISBLK(mode_t)
    mode_t S_ISFIFO(mode_t)
    mode_t S_ISLNK(mode_t)
    mode_t S_ISSOCK(mode_t)

    mode_t S_IFMT
    mode_t S_IFREG
    mode_t S_IFDIR
    mode_t S_IFCHR
    mode_t S_IFBLK
    mode_t S_IFIFO
    mode_t S_IFLNK
    mode_t S_IFSOCK

    # Permissions
    mode_t S_ISUID
    mode_t S_ISGID
    mode_t S_ISVTX

    mode_t S_IRWXU
    mode_t S_IRUSR
    mode_t S_IWUSR
    mode_t S_IXUSR

    mode_t S_IRWXG
    mode_t S_IRGRP
    mode_t S_IWGRP
    mode_t S_IXGRP

    mode_t S_IRWXO
    mode_t S_IROTH
    mode_t S_IWOTH
    mode_t S_IXOTH


# Cypclass to expose minimal stat support.

cdef cypclass Stat:
    struct_stat st_data

    Stat __new__(alloc, string path):
        instance = alloc()
        if not lstat(path.c_str(), &instance.st_data):
            return instance

    bint is_regular(self):
        return S_ISREG(self.st_data.st_mode)

    bint is_symlink(self):
        return S_ISLNK(self.st_data.st_mode)

    bint is_dir(self):
        return S_ISDIR(self.st_data.st_mode)

    string to_json(self):
        return sprintf("""{
        "st_dev": %lu,
        "st_ino": %lu,
        "st_mode": %lu,
        "st_nlink": %lu,
        "st_uid": %d,
        "st_gid": %d,
        "st_rdev": %lu,
        "st_size": %ld,
        "st_blksize": %ld,
        "st_blocks": %ld,
        "st_atime": %ld,
        "st_mtime": %ld,
        "st_ctime": %ld
      }""",
            self.st_data.st_dev,
            self.st_data.st_ino,
            self.st_data.st_mode,
            self.st_data.st_nlink,
            self.st_data.st_uid,
            self.st_data.st_gid,
            self.st_data.st_rdev,
            self.st_data.st_size,
            self.st_data.st_blksize,
            self.st_data.st_blocks,
            self.st_data.st_atime,
            self.st_data.st_mtime,
            self.st_data.st_ctime
        )
