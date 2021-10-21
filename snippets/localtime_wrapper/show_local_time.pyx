# distutils: language = c++
from localtime cimport now_local
from localtime import py_now_local
from stdlib.string cimport string
from stdlib.fmt cimport printf



cdef void cython_local_time() nogil:
    with nogil:
        printf("without GIL:\n")
        printf("%s\n", now_local())



def main():
    cython_local_time()
    print("with GIL:")
    print(py_now_local())
