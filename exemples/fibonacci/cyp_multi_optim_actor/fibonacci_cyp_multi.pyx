# distutils: language = c++
# Fibonacci x 100, cythonplus multicore, optimized, result as actor"
from libcythonplus.dict cimport cypdict
from scheduler.persistscheduler cimport SequentialMailBox, NullResult, PersistScheduler



cdef cypclass Fibo activable:
    long level
    active Recorder recorder

    __init__(self,
             lock PersistScheduler scheduler,
             active Recorder recorder,
             long level):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.recorder = recorder
        self.level = level


    void run(self):
        cdef double a, b

        a = 0.0
        b = 1.0
        for i in range(self.level):
            a, b = b, a + b
        self.recorder.record(NULL, self.level, a)



cdef cypclass Recorder activable:
    cypdict[long, double] storage

    __init__(self, lock PersistScheduler scheduler):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.storage = cypdict[long, double]()


    void record(self, long key, double value):
        self.storage[key] = value


    cypdict[long, double] dump(self):
        return self.storage



cdef cypclass FiboGenerator activable:
    lock PersistScheduler scheduler
    long size
    active Recorder recorder

    __init__(self, lock PersistScheduler scheduler, long size):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        # keep scheduler for use with Fibo instances when run() :
        self.scheduler = scheduler
        self.size = size
        self.recorder = activate (consume Recorder(scheduler))


    void run(self):
        cdef long level
        # reverse order to ensure longest computations launched early :
        for level in range(self.size, -1, -1):
            fibo = activate(consume Fibo(self.scheduler, self.recorder, level))
            fibo.run(NULL)


    cypdict[long, double] dump(self):
        recorder = consume self.recorder  # to stop the active state
        return <cypdict[long, double]> recorder.dump()



cdef cypdict[long, double] compute_fibo_sequence(long size) nogil:
    cdef active FiboGenerator generator
    cdef lock PersistScheduler scheduler

    # need to generate a new scheduler each time, to be able to consume the generator
    scheduler = PersistScheduler()
    generator = activate(consume FiboGenerator(scheduler, size))
    generator.run(NULL)
    scheduler.finish()
    consumed_generator = consume generator  # to stop active state
    return <cypdict[long, double]> consumed_generator.dump()



cdef py_fibo_one(long size):
    cdef cypdict[long, double] results

    with nogil:
        results = compute_fibo_sequence(size)

    py_results = sorted([(i, results[i]) for i in range(size + 1)])
    return py_results



cdef list py_fibo_many(long size, int repeat):
    many = []
    for i in range(repeat):
        many.append(py_fibo_one(size))
    return many



def fibo_many(size=None, repeat=100):
    if not size:
        size = 1476
    if not repeat:
        repeat = 100
    size = int(size)
    repeat = int(repeat)
    return py_fibo_many(size, repeat)
