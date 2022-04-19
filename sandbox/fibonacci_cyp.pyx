from libcythonplus.dict cimport cypdict
from .scheduler.scheduler cimport SequentialMailBox, NullResult, Scheduler


cdef cypclass Fibo activable:
    long level
    lock cypdict[long, double] results

    __init__(self,
             lock Scheduler scheduler,
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


cdef lock cypdict[long, double] fibo_list_cyp(
        lock Scheduler scheduler,
        long level) nogil:
    cdef lock cypdict[long, double] results

    results = consume cypdict[long, double]()

    for n in range(level, -1, -1):  # reverse order to compute first the big numbers
        fibo = activate(consume Fibo(scheduler, results, n))
        fibo.run(NULL)

    scheduler.finish()
    return results


cdef list fibo_list(int level):
    cdef cypdict[long, double] results_cyp
    cdef list result_py
    cdef lock Scheduler scheduler

    scheduler = Scheduler()
    results_cyp = consume fibo_list_cyp(scheduler, level)
    del scheduler

    result_py = [item[1] for item in
                    sorted((i, results_cyp[i]) for i in range(level + 1))
                ]
    return result_py


def main(level=None):
    if not level:
        level = 1476
    result = fibo_list(int(level))
    # print(f"Computed values: {len(result)=}, Fibonacci({level}) is: {result[-1]=}")
    print(f"Computed values: len(result)={len(result)}, Fibonacci({level}) is: result[-1]={result[-1]}")
