# distutils: language = c++

# golomb sequence

from libcythonplus.dict cimport cypdict
from runtime.runtime cimport SequentialMailBox, BatchMailBox, NullResult, Scheduler



cdef long g(long n) nogil:
    """Return the value of position n of the Golomb sequence (recursice function).
    """
    if n == 1:
        return 1
    return g(n - g(g(n - 1))) + 1



cdef cypclass Golomb activable:
    long rank

    __init__(self, lock Scheduler scheduler, long rank):
        self._active_result_class = NullResult
        self._active_queue_class = consume SequentialMailBox(scheduler)
        self.rank = rank


    # long g(self, long n):
    #     """Return the value of position n of the Golomb sequence (recursice function).
    #     """
    #     if n == 1:
    #         return 1
    #     return self.g(n - self.g(self.g(n - 1))) + 1


    void compute(self, lock cypdict[long, long] results):
        cdef long value

        # value = self.g(self.rank)
        value = g(self.rank)
        results[self.rank] = value



cdef lock cypdict[long, long] golomb_sequence(long size) nogil:
    cdef lock Scheduler scheduler
    cdef lock cypdict[long, long] results

    results = consume cypdict[long, long]()
    scheduler = Scheduler()

    for i in range(1, size+1):
        golomb = Golomb(scheduler, i)
        agolomb = <active Golomb> activate(consume golomb)
        agolomb.compute(NULL, results)
    scheduler.finish()
    del scheduler

    return results


cdef py_golomb_sequence(long size):
    cdef lock cypdict[long, long] results

    with nogil:
        results = golomb_sequence(size)

    py_results = sorted([(i, results[i]) for i in range(1, size+1)])
    del results
    return py_results


def main(size=None):
    if not size:
        size = 50
    print(py_golomb_sequence(int(size)))



# jd@fuseki:~/abi/cythonplus-sandbox/exemples/golomb_cyplus_multicore$ ./launcher.py
# Data Race between [this] writer #1337582 and [other] writer #1337580 on lock 0x2982c50
# In [this] context: runtime/runtime.pxd:34:21
#         with wlocked queue:
#                      ^
# munmap_chunk(): invalid pointer
# Aborted (core dumped)






# Error compiling Cython file:
# ------------------------------------------------------------
# ...
#     lst = Glist()
#
#     with nogil:
#         for i in range(1, size+1):
#             g = Golomb(scheduler, i)
#             g.set_list(address(lst))
#                       ^
# ------------------------------------------------------------
#
# golomb.pyx:49:23: Cannot take address of cypclass
# Traceback (most recent call last):
#   File "setup.py", line 26, in <module>
#     ext_modules=cythonize(
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Build/Dependencies.py", line 1110, in cythonize
#     cythonize_one(*args)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Build/Dependencies.py", line 1277, in cythonize_one
#     raise CompileError(None, pyx_file)
# Cython.Compiler.Errors.CompileError: golomb.pyx
# jd@fuseki:~/abi/cythonplus-sandbox/exemples/golomb_cyplus_multicore$
#

#
# Error compiling Cython file:
# ------------------------------------------------------------
# ...
#     lst = Glist()
#
#     with nogil:
#         for i in range(1, size+1):
#             g = Golomb(scheduler, i)
#             g.set_list(&lst)
#                       ^
# ------------------------------------------------------------
#
# golomb.pyx:48:23: Cannot take address of cypclass
# Traceback (most recent call last):
#   File "setup.py", line 26, in <module>
#     ext_modules=cythonize(
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Build/Dependencies.py", line 1110, in cythonize
#     cythonize_one(*args)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Build/Dependencies.py", line 1277, in cythonize_one
#     raise CompileError(None, pyx_file)
# Cython.Compiler.Errors.CompileError: golomb.pyx
#
