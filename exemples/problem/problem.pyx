# distutils: language = c++

from libcythonplus.dict cimport cypdict
from scheduler.persistscheduler cimport SequentialMailBox, NullResult, PersistScheduler
from libc.stdio cimport printf


cdef cypclass Calculator activable:
    active Recorder recorder
    long level

    __init__(self,
             lock PersistScheduler scheduler,
             active Recorder recorder,
             long level):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.recorder = recorder
        self.level = level


    void run(self):
        cdef long a

        a = 42
        self.recorder.record(NULL, self.level, a)



cdef cypclass Recorder activable:
    cypdict[long, long] storage

    __init__(self, lock PersistScheduler scheduler):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.storage = cypdict[long, long]()


    void record(self, long key, long value):
        self.storage[key] = value


    cypdict[long, long] dump(self):
        return self.storage



cdef cypclass MultiCalculator activable:
    lock PersistScheduler scheduler
    long size
    active Recorder recorder

    __init__(self, lock PersistScheduler scheduler, long size):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        # keep scheduler for use with Calculator instance when run() :
        self.scheduler = scheduler
        self.size = size
        self.recorder = activate(consume Recorder(scheduler))


    void run(self):
        for level in range(self.size):
            calc = activate(consume Calculator(self.scheduler, self.recorder, level))
            # do not store the calc instances in a list, directly run them:
            calc.run(NULL)


    cypdict[long, long] dump(self):
        cdef Recorder r

        r = consume self.recorder  # to stop the active state
        return r.dump()



cdef cypdict[long, long] compute_sequence(long size) nogil:
    cdef active MultiCalculator mc
    cdef lock PersistScheduler scheduler

    # generate a new scheduler each time
    scheduler = PersistScheduler()
    mc = activate(consume MultiCalculator(scheduler, size))
    mc.run(NULL)
    scheduler.finish()
    del scheduler  # is it ok here?
    consumed_calc = consume mc  # to stop active state
    return <cypdict[long, long]> consumed_calc.dump()



cdef py_compute_one(long size):
    cdef cypdict[long, long] results

    with nogil:
        results = compute_sequence(size)
    py_results = sorted([(i, results[i]) for i in range(size)])
    return py_results



cdef py_compute_many(long size, long many):
    many_seq = []
    for i in range(many):
        print(i)
        many_seq.append(py_compute_one(size))
    return many_seq



def make_one(size=None):
    if not size:
        size = 20
    print(py_compute_one(size))



def make_many(size=None, many=None):
    if not size:
        size = 20
    if not many:
        many = 100
    lst = py_compute_many(size, many)
    print(f"len:{len(lst)}, last: {lst[-1]}")
