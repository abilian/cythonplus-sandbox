# distutils: language = c++
# golomb sequence

from libcythonplus.dict cimport cypdict
from scheduler.persistscheduler cimport SequentialMailBox, NullResult, PersistScheduler
from libc.stdio cimport printf



cdef long g(long n) nogil:
    """Return the value of position n of the Golomb sequence (recursice function).
    """
    if n == 1:
        return 1
    return g(n - g(g(n - 1))) + 1



cdef cypclass Golomb activable:
    long rank
    long value

    __init__(self, long rank):
        self.rank = rank
        self.value = 0

    void run(self):
        self.value = g(self.rank)

    long result(self):
        return self.value


cdef cypclass GolombList activable:
    long size
    lock cypdict[long, long] results

    __init__(self, long size):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(PersistScheduler())
        self.size = size

    cypdict[long, long] run(self):
        cdef cypdict[long, long] results

        results = consume cypdict[long, long]()
        for i in range(1, size + 1):
            golomb = <active Golomb> activate(consume Golomb(i))
            golomb.run(NULL)
            printf("%ld\n", i)
            printf("%ld\n", golomb.result(NULL))
            results[i] = golomb.result(NULL)
        scheduler.finish()
        return results


cdef lock cypdict[long, long] golomb_sequence(long size) nogil:
    cdef cypdict[long, long] results
    cdef GolombList gl

    gl = GolombList(size)
    return gl.run()


cpdef py_golomb_sequence(long size):
    cdef cypdict[long, long] results

    with nogil:
        results = golomb_sequence(size)

    py_results = sorted([(i, results[i]) for i in range(1, size+1)])
    return py_results


def main(size=None):
    if not size:
        size = 50
    print(py_golomb_sequence(int(size)))
