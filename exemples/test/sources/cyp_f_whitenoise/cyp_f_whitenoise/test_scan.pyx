# distutils: language = c++
from libc.stdio cimport printf, puts
from stdlib._string cimport string
from stdlib.string cimport Str

from .scan cimport Fdict, scan_fs_dic
from .abspath cimport abspath

def main():
    root = abspath(Str(b"."))
    cache = scan_fs_dic(root)
    print("cache size:", cache.__len__())
