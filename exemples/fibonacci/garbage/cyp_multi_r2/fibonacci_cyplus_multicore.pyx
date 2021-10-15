# distutils: language = c++
from libcythonplus.dict cimport cypdict
from scheduler.persistscheduler cimport SequentialMailBox, NullResult, PersistScheduler
from libc.stdio cimport printf


cdef cypclass Fibo activable:
    long level

    __init__(self, lock PersistScheduler scheduler, long level):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.level = level

    void compute(self, lock cypdict[long, double] results):
        cdef double a, b, tmp
        a = 0.0
        b = 1.0
        tmp = 0.0

        for i in range(self.level):
            tmp = a
            a = b
            b = tmp + b
        with wlocked results:
            results[self.level] = a


cdef lock cypdict[long, double] fibo_sequence(long size) nogil:
    cdef lock PersistScheduler scheduler
    cdef lock cypdict[long, double] results

    results = consume cypdict[long, double]()
    scheduler = PersistScheduler()

    for i in range(size+1):
        # fibo = Fibo(scheduler, i)
        afibo = <active Fibo> activate(consume Fibo(scheduler, i))
        afibo.compute(NULL, results)

    scheduler.join()
    scheduler.finish()
    del scheduler

    return results


cdef py_fibo_sequence(long size):
    cdef lock cypdict[long, double] results
    with nogil:
        results = fibo_sequence(size)

    py_results = sorted([(i, results[i]) for i in range(size+1)])
    del results
    return py_results


def main(size=None):
    if not size:
        size = 1476
    for item in py_fibo_sequence(int(size))[-3:]:
        print(f"{item[0]}: {item[1]:.1f}, ", end= "")
    print()
