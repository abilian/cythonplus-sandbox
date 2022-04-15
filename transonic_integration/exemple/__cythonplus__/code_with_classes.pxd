# distutils: language = c++

# Frequently cimported:
from libc.stdio cimport *

from libcythonplus.list cimport cyplist
from libcythonplus.dict cimport cypdict
from libcythonplus.set cimport cypset

from stdlib.string cimport Str
from stdlib._string cimport string
from stdlib.format cimport format


cdef cypclass Golomb activable:
    int rank
    int value

    __init__(self, int rank):
        cdef int loc
        loc = 0

        # for activable cypclass defaults:
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        # Default initialization of attributes:
        self.rank = 0
        self.value = 0

        loc = 5
        self.rank = rank + loc
        g = Gpos(rank)
        self.value = g.gpos(rank)

    void some_meth(self, Str param):
        self.value = len(param)


cdef cypclass Gpos:
    double flrank
    cyplist[int] xrank
    int gpos
    Str message

    __init__(self, int rank, double ratio, Str msg):
        # Default initialization of attributes:
        self.flrank = 0.0
        self.xrank = cyplist[int]()
        self.gpos = 0
        self.message = Str("")

        self.flrank = 1.0 + ratio
        self.message = msg

    int gpos(self, int n):
        """Return the value of position n of the Golomb sequence (recursive function).
        """
        if n == 1:
            return 1
        return self.gpos(n - self.gpos(self.gpos(n - 1))) + 1

    int another_gpos(self, int n):
        """Return the value of position n of the Golomb sequence (recursive function).
        """
        if n == 1:
            return 1
        return self.gpos(n - self.gpos(self.gpos(n - 1))) + 1


cdef cypclass Recorder:
    cypdict[int, int] storage
    cypdict[Str, int] txt_storage

    __init__(self):
        # Default initialization of attributes:
        self.storage = cypdict[int, int]()
        self.txt_storage = cypdict[Str, int]()

        self.storage = {}
        self.txt_storage = {}

    void store(self, int key, int value):
        self.storage[key] = value
        self.txt_storage[str(key)] = value

    cypdict[Str, int] content(self):
        return self.txt_storage
