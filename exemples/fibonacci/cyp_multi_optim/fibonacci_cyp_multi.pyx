# distutils: language = c++
# Fibonacci x 100, cythonplus multicore, optimized, joined scheduler
from libcythonplus.dict cimport cypdict
from scheduler.persistscheduler cimport SequentialMailBox, NullResult, PersistScheduler


cdef cypclass Fibo activable:
    long level
    lock cypdict[long, double] results

    __init__(self,
             lock PersistScheduler scheduler,
             lock cypdict[long, double] results,
             long level):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.level = level
        self.results = results


    void run(self):
        cdef double a, b

        a = 0.0
        b = 1.0
        for i in range(self.level):
            a, b = b, a + b
        with wlocked self.results:
            self.results[self.level] = a



cdef lock cypdict[long, double] fibo_sequence_sch(lock PersistScheduler scheduler,
                                                  long size) nogil:
    cdef lock cypdict[long, double] results

    results = consume cypdict[long, double]()

    for i in range(size, -1, -1):  # reverse computation order to make big ones early
        fibo = activate(consume Fibo(scheduler, results, i))
        fibo.run(NULL)

    scheduler.join()
    return results



cdef py_fibo_sequence_sch(lock PersistScheduler scheduler, long size):
    cdef lock cypdict[long, double] results

    with nogil:
        results = fibo_sequence_sch(scheduler, size)

    py_results = sorted([(i, results[i]) for i in range(size + 1)])
    del results
    return py_results



cdef list py_fibo_many(int size, int repeat):
    cdef list many = []
    cdef lock PersistScheduler scheduler

    # keep schedulr between cycles
    scheduler = PersistScheduler()
    for i in range(repeat):
        many.append(py_fibo_sequence_sch(scheduler, size))

    scheduler.finish()
    del scheduler
    return many



def fibo_many(size=None, repeat=100):
    if not size:
        size = 1476
    if not repeat:
        repeat = 100
    size = int(size)
    repeat = int(repeat)
    return py_fibo_many(size, repeat)
