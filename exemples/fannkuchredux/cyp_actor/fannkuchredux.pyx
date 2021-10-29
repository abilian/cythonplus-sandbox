# distutils: language = c++
# fannkuchredux, cythonplus actor
# Tried different chunk_size:
# chunk_size = (factorial(length) + nb_cpu - 1) // nb_cpu  (original, aka 1 group/cpu)
# chunk_size = 1
# chunk_size = max(1, factorial(length) // 64 // nb_cpu)  (seems better, 64 group/cpu)
#
# taken from fannkuchredux.pyx in:
# " The Computer Language Benchmarks Game
#   http://benchmarksgame.alioth.debian.org/
#
#   contributed by Jacek Pliszka
#   algorithm is based on Java 6 source code by Oleg Mazurov
#   source is based on Miroslav Rubanets' C++ submission.
#   converted to python by Ian P. Cooke
#   converted to generators by Jacek Pliszka
# "

import os
from libcpp.algorithm cimport copy, reverse
from libcythonplus.dict cimport cypdict
from libcythonplus.list cimport cyplist
from stdlib.fmt cimport printf
from scheduler.persistscheduler cimport SequentialMailBox, NullResult, PersistScheduler


ctypedef cyplist[int] IntList

cdef int MAX_PROBLEM_SIZE
MAX_PROBLEM_SIZE = 12


# cdef void print_list(IntList lst) nogil:
#     for i in range(lst.__len__()):
#         printf("%d ", <int> lst[i])
#     printf("\n")


cdef void reverse_list(IntList lst) nogil:
    if lst._active_iterators == 0:
        reverse(lst._elements.begin(), lst._elements.end())
    else:
        with gil:
            raise RuntimeError("Modifying a list with active iterators")


cdef int max_list(IntList lst) nogil:
    cdef int m
    if lst.__len__() == 0:
        with gil:
            raise ValueError("max() arg is an empty sequence")
    m = lst[0]
    for e in lst:
        m = max(m, e)
    return m


cdef int sum_list(IntList lst) nogil:
    cdef int s, e
    s = 0
    for e in lst:
        s += e
    return s


cdef IntList copy_list(IntList lst) nogil:
    cdef IntList result = IntList()

    if lst._active_iterators == 0:
        result._elements = lst._elements
        return result
    else:
        with gil:
            raise RuntimeError("Modifying a list with active iterators")


cdef IntList copy_slice(IntList lst, size_t start, size_t end) nogil:
    cdef IntList result = IntList()

    if lst._active_iterators == 0:
        for i in range(start, end):
            result._elements.push_back(lst[i])
        return result
    else:
        with gil:
            raise RuntimeError("Modifying a list with active iterators")


cdef IntList copy_slice_from(IntList lst, size_t start) nogil:  # size_type
    return copy_slice(lst, start, lst._elements.size())


cdef IntList copy_slice_to(IntList lst, size_t end) nogil:  # size_type
    return copy_slice(lst, 0, end)


cdef IntList range_to_list(int length) nogil:
    cdef IntList lst
    cdef int i

    lst = IntList()
    for i in range(length):
        lst.append(i)
    return lst


cdef int factorial(int n) nogil:
    "int factorial() : limit argument to 12 or overflow if int is 32bits"
    cdef int a, i
    if n <= 1:
        return 1
    elif n == 2:
        return 2
    elif n == 3:
        return 6
    elif n == 4:
        return 24
    elif n == 5:
        return 120
    elif n == 6:
        return 720
    elif n == 7:
        return 5040
    elif n == 8:
        return 40320
    elif n == 9:
        return 362880
    elif n == 10:
        return 3628800
    a = 3628800
    for i in range(11, n + 1):
        a = a * i
    return a



cdef cypclass Pair:
    int a
    int b

    __init__(self, int a, int b):
        self.a = a
        self.b = b



cdef cypclass Recorder activable:
    cyplist[Pair] storage

    __init__(self, lock PersistScheduler scheduler):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.storage = cyplist[Pair]()

    void store(self, int a, int b):
        cdef Pair pair

        pair = Pair(a, b)
        self.storage.append(pair)

    cyplist[Pair] content(self):
        return self.storage



cdef cypclass FKActor activable:
    int length
    int begin
    int end
    bint initalized
    IntList perm, count
    active Recorder recorder

    __init__(self,
             lock PersistScheduler scheduler,
             active Recorder recorder,
             int length,
             int begin,
             int end):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.length = length
        self.begin = begin
        self.end = end
        self.recorder = recorder
        self.initalized = 0


    void first_permutation(self):
        cdef IntList p1, p2, p3
        cdef int i, d, idx, fact_i

        self.perm = range_to_list(self.length)
        self.count = IntList()
        self.count.append(0)
        self.count = self.count * self.length
        idx = self.begin
        for i in range(self.length - 1, 0, -1):
            fact_i = factorial(i)
            d = idx // fact_i
            idx = idx % fact_i
            self.count[i] = d
            p1 = copy_slice_to(self.perm, d)
            p2 = copy_slice(self.perm, d, i + 1)
            p3 = copy_slice_from(self.perm, i + 1)
            self.perm = p2 + p1 + p3


    void next_permutation(self):
        cdef IntList p1, p2, p3
        cdef int i, tmp

        if not self.initalized:
            self.first_permutation()
            self.initalized = 1
            return

        # rotate
        tmp = self.perm[0]
        self.perm[0] = self.perm[1]
        self.perm[1] = tmp

        self.count[1] = self.count[1] + 1
        i = 1
        while self.count[i] > i:
            self.count[i] = 0
            i += 1
            if i >= self.length:
                break
            self.count[i] = self.count[i] + 1
            # rotate
            p1 = copy_slice_to(self.perm, 1)
            p2 = copy_slice(self.perm, 1, i + 1)
            p3 = copy_slice_from(self.perm, i + 1)
            self.perm = p2 + p1 + p3


    void run(self):
        cdef IntList data, p1, p2
        cdef int maxflips, checksum, flips, f, i

        maxflips = 0
        checksum = 0
        for i in range(self.begin, self.end):
            self.next_permutation()
            if self.perm[0] > 0:
                data = copy_list(self.perm)
                f = data[0]
                flips = 0
                while f > 0:
                    p1 = copy_slice_to(data, f + 1)
                    reverse_list(p1)
                    p2 = copy_slice_from(data, f + 1)
                    data = p1 + p2
                    flips += 1
                    f = data[0]
                maxflips = max(maxflips, flips)
                if i % 2:
                    checksum -= flips
                else:
                    checksum += flips
        self.recorder.store(NULL, maxflips, checksum)



cdef cypclass FKGenerator activable:
    int length
    int index_max
    int chunk_size
    lock PersistScheduler scheduler
    active Recorder recorder

    __init__(self, lock PersistScheduler scheduler, int length, int chunk_size):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.scheduler = scheduler  # keep it for use with sub objects
        self.length = length
        self.recorder = activate (consume Recorder(scheduler))
        self.index_max = factorial(self.length)
        self.chunk_size = chunk_size


    void run(self):
        cdef int i

        # bug ?
        # for i in range(0, self.index_max, self.chunk_size):
                  # Coercion from Python not allowed without the GIL

        i = 0
        while i < self.index_max:
            fk_actor = <active FKActor> activate(consume FKActor(
                self.scheduler,
                self.recorder,
                self.length,
                i,
                i + self.chunk_size
            ))
            fk_actor.run(NULL)
            i += self.chunk_size


    cyplist[Pair] results(self):
        recorder = consume self.recorder
        return <cyplist[Pair]> recorder.content()



cdef cyplist[Pair] fk_results(int length, int nb_cpu) nogil:
    cdef active FKGenerator generator
    cdef lock PersistScheduler scheduler
    cdef int chunk_size

    # chunk_size = (factorial(length) + nb_cpu - 1) // nb_cpu
    # chunk_size = 1
    chunk_size = max(1, factorial(length) // 64 // nb_cpu)
    scheduler = PersistScheduler()
    generator = activate(consume FKGenerator(scheduler, length, chunk_size))
    generator.run(NULL)
    scheduler.finish()
    del scheduler
    consumed = consume(generator)
    return <cyplist[Pair]> consumed.results()


cpdef py_main_fk(int length):
    # result fo length 10:
    # 73196
    # Pfannkuchen(10) = 38
    cdef cyplist[Pair] results
    cdef IntList flips, checksums
    cdef int nb_cpu, max_flips, sum_chk

    nb_cpu = os.cpu_count()
    flips = IntList()
    checksums = IntList()
    with nogil:
        results = fk_results(length, nb_cpu)
        # next lines could also be in "gil" pure python:
        for r in results:
            flips.append(r.a)
            checksums.append(r.b)
        # print_list(flips)
        # print_list(checksums)
        max_flips = max_list(flips)
        sum_chk = sum_list(checksums)
        printf("%d\nPfannkuchen(%d) = %d\n", sum_chk, length, max_flips)


usage = """usage fannkuchredux number
number has to be in range [3-12]\n"""


def main(length=None):
    if not length:
        length = 11
    length = int(length)
    if length < 3 or length > MAX_PROBLEM_SIZE:
        print(usage)
    py_main_fk(length)
