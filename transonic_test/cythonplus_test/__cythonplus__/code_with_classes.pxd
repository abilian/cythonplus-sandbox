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

    __init__(self, int rank):
        cdef int loc
        loc = 0

        # for actavable cypclass defaults:
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        loc = 5
        self.rank = rank + loc
        g = Gpos(rank)
        self.value = g.gpos(rank)

    void some_meth(self, Str param):
        self.value = len(param)


cdef cypclass Gpos:

    __init__(self, int rank):
        print('44')
        self.xrank = rank

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

    __init__(self):
        self.storage = {}

    void store(self, int key, int value):
        self.storage[key] = value

    cypdict[Str, int] content(self):
        return self.storage
