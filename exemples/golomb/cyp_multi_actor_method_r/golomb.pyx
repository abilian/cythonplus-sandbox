# distutils: language = c++
# golomb sequence
# cythonplus multicore, implementation with actors, with instance
# method, reverse order

from libcythonplus.dict cimport cypdict
IF UNAME_SYSNAME == "Darwin":
    from scheduler_darwin.scheduler cimport SequentialMailBox, NullResult, Scheduler
ELSE:
    from scheduler.scheduler cimport SequentialMailBox, NullResult, Scheduler


cdef cypclass Golomb activable:
    long rank
    active Recorder recorder

    __init__(self,
             lock Scheduler scheduler,
             active Recorder recorder,
             long rank):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.rank = rank
        self.recorder = recorder

    long gpos(self, long n):
        """Return the value of position n of the Golomb sequence (recursive function).
        """
        if n == 1:
            return 1
        return self.gpos(n - self.gpos(self.gpos(n - 1))) + 1

    void run(self):
        cdef long value

        value = self.gpos(self.rank)
        self.recorder.store(NULL, self.rank, value)


cdef cypclass Recorder activable:
    cypdict[long, long] storage

    __init__(self, lock Scheduler scheduler):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.storage = cypdict[long, long]()

    void store(self, long key, long value):
        self.storage[key] = value

    cypdict[long, long] content(self):
        return self.storage


cdef cypclass GolombGenerator activable:
    long size
    lock Scheduler scheduler
    active Recorder recorder

    __init__(self, lock Scheduler scheduler, long size):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.scheduler = scheduler  # keep it for use with sub objects
        self.size = size
        self.recorder = activate (consume Recorder(scheduler))

    void run(self):
        # reverse order to ensure longest computations launched early :
        for rank in range(self.size, 0, -1):
            golomb = <active Golomb> activate(consume Golomb(self.scheduler,
                                                             self.recorder,
                                                             rank))
            golomb.run(NULL)

    cypdict[long, long] results(self):
        recorder = consume self.recorder  # strange construct ?
        return <cypdict[long, long]> recorder.content()


cdef cypdict[long, long] golomb_sequence(long size) nogil:
    cdef active GolombGenerator generator
    cdef lock Scheduler scheduler

    scheduler = Scheduler()
    generator = activate(consume GolombGenerator(scheduler, size))
    generator.run(NULL)
    scheduler.finish()
    del scheduler
    consumed = consume(generator)
    return <cypdict[long,long]> consumed.results()


cpdef py_golomb_sequence(long size):
    cdef cypdict[long, long] results

    with nogil:
        results = golomb_sequence(size)

    sequence = sorted([(i, results[i]) for i in range(1, size + 1)])
    return sequence


def main(size=None):
    if not size:
        size = 50
    print(py_golomb_sequence(int(size)))
