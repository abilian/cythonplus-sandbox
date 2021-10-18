# distutils: language = c++
# golomb sequence
# cythonplus multicore, 'with wlocked' implementation

from libcythonplus.dict cimport cypdict
from scheduler.persistscheduler cimport SequentialMailBox, NullResult, PersistScheduler



cdef long gpos(long n) nogil:
    """Return the value of position n of the Golomb sequence (recursive function).
    """
    if n == 1:
        return 1
    return gpos(n - gpos(gpos(n - 1))) + 1



cdef cypclass Golomb activable:
    long rank
    lock cypdict[long, long] results

    __init__(self,
             lock SequentialMailBox mailbox,
             lock cypdict[long, long] results,
             long rank):
        self._active_result_class = NullResult
        self._active_queue_class = mailbox
        self.rank = rank
        self.results = results

    void run(self):
        cdef long value

        value = gpos(self.rank)
        with wlocked self.results:
            self.results[self.rank] = value



cdef lock cypdict[long, long] golomb_sequence(long size) nogil:
    cdef lock PersistScheduler scheduler
    cdef lock cypdict[long, long] results
    cdef lock SequentialMailBox mailbox

    results = consume cypdict[long, long]()
    scheduler = PersistScheduler()

    for i in range(1, size + 1):
        mailbox = consume SequentialMailBox(scheduler)
        golomb = <active Golomb> activate(consume Golomb(mailbox, results, i))
        golomb.run(NULL)
    scheduler.finish()
    del scheduler
    return results


cpdef py_golomb_sequence(long size):
    cdef lock cypdict[long, long] results

    with nogil:
        results = golomb_sequence(size)

    py_results = sorted([(i, results[i]) for i in range(1, size+1)])
    return py_results


def main(size=None):
    if not size:
        size = 50
    print(py_golomb_sequence(int(size)))
