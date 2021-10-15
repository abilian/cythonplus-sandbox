# distutils: language = c++
from libcythonplus.dict cimport cypdict
from scheduler.persistscheduler cimport SequentialMailBox, NullResult, PersistScheduler
from libc.stdio cimport printf


cdef cypclass Fibo activable:
    long level
    lock cypdict[long, double] results

    __init__(self,
             lock SequentialMailBox mailbox,
             # lock PersistScheduler scheduler,
             lock cypdict[long, double] results,
             long level):
        self._active_result_class = NullResult
        # self._active_queue_class = consume SequentialMailBox(scheduler)
        self._active_queue_class = mailbox
        self.level = level
        self.results = results

    void run(self):
        cdef double a, b, tmp
        a = 0.0
        b = 1.0

        for i in range(self.level):
            a, b = b, a + b

        # printf("%ld %lf\n", self.level, a)
        with wlocked self.results:
            self.results[self.level] = a



cdef lock cypdict[long, double] fibo_sequence(long size) nogil:
    cdef lock PersistScheduler scheduler
    cdef lock cypdict[long, double] results
    cdef lock SequentialMailBox mailbox

    results = consume cypdict[long, double]()
    scheduler = PersistScheduler()

    for i in range(size+1):
        # fibo = Fibo(scheduler, i)
        mailbox = consume SequentialMailBox(scheduler)
        afibo = <active Fibo> activate(consume Fibo(mailbox, results, i))
        afibo.run(NULL)
        # afibo.compute(NULL, results)

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


def print_summary(sequence):
    for item in (sequence[0], sequence[1], sequence[-1]):
        print(f"{item[0]}: {item[1]:.1f}, ")


def main(size=None):
    if not size:
        size = 1476
    print_summary(py_fibo_sequence(int(size)))
