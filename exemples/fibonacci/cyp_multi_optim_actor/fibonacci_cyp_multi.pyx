# distutils: language = c++
# Fibonacci x 100, cythonplus multicore, keep scheduler, result as actor

from libcythonplus.dict cimport cypdict
from scheduler.persistscheduler cimport SequentialMailBox, NullResult, PersistScheduler
from libc.stdio cimport printf


cdef cypclass Fibo activable:
    long level
    active Recorder recorder

    __init__(self,
             lock PersistScheduler scheduler,
             active Recorder recorder,
             long level):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.level = level
        self.recorder = recorder


    void run(self):
        cdef double a, b, tmp
        a = 0.0
        b = 1.0

        for i in range(self.level):
            a, b = b, a + b

        self.recorder.store(NULL, self.level, a)



cdef cypclass Recorder activable:
    cypdict[long, double] storage

    __init__(self, lock PersistScheduler scheduler):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.storage = cypdict[long, double]()

    void store(self, long key, double value):
        self.storage[key] = value

    cypdict[long, double] content(self):
        return self.storage



cdef cypclass FiboGenerator activable:
    long size
    lock PersistScheduler scheduler
    active Recorder recorder

    __init__(self, lock PersistScheduler scheduler, long size):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.scheduler = scheduler  # keep it for use with sub objects
        self.size = size
        self.recorder = activate (consume Recorder(scheduler))

    void run(self):
        # reverse order to ensure longest computations launched early :
        for level in range(self.size, -1, -1):
            fibo = <active Fibo> activate(consume Fibo(self.scheduler,
                                                       self.recorder,
                                                       level))
            fibo.run(NULL)

    cypdict[long, double] results(self):
        recorder = consume self.recorder  # strange construct ?
        return <cypdict[long, double]> recorder.content()



cdef cypdict[long, double] fibo_sequence(long size) nogil:
    cdef active FiboGenerator generator
    cdef lock PersistScheduler scheduler

    # need to generate a new scheduler each time, to be able to consume the generator
    scheduler = PersistScheduler()
    generator = activate(consume FiboGenerator(scheduler, size))
    generator.run(NULL)
    scheduler.finish()
    consumed = consume(generator)
    return <cypdict[long, double]> consumed.results()



cdef py_fibo_sequence(long size):
    cdef cypdict[long, double] results

    with nogil:
        results = fibo_sequence(size)

    py_results = sorted([(i, results[i]) for i in range(size + 1)])
    del results

    return py_results



def print_summary(sequence):
    for item in (sequence[0], sequence[1], sequence[-1]):
        print(f"{item[0]}: {item[1]:.1f}, ")



def main(size=None):
    if not size:
        size = 1476
    print_summary(cyp_fibo_many(int(size), 100))



cdef list cyp_fibo_many(long size, int repeat):
    many = []

    for i in range(repeat):
        printf("--- repeat %d\n", i)
        many.append(py_fibo_sequence(size))

    return many



def fibo_many(size=None, repeat=100):
    if not size:
        size = 1476
    size = int(size)
    repeat = int(repeat)
    return cyp_fibo_many(size, repeat)
