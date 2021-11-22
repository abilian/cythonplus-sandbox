# cdef extern from "<sys/types.h>" nogil:
#     ctypedef long unsigned int pthread_t
#
#     ctypedef union pthread_attr_t:
#         pass
#     ctypedef union pthread_mutex_t:
#         pass
#     ctypedef union pthread_mutexattr_t:
#         pass
#     ctypedef union pthread_cond_t:
#         pass
#     ctypedef union pthread_condattr_t:
#         pass

cdef extern from "runtime/pthread_barrier.h" nogil:
    ctypedef union pthread_barrier_t:
        pass
    ctypedef union pthread_barrierattr_t:
        pass


cdef extern from "runtime/pthread_barrier.h" nogil:
    int pthread_barrier_init(pthread_barrier_t *, const pthread_barrierattr_t *, unsigned int)
    int pthread_barrier_destroy(pthread_barrier_t *)
    int pthread_barrier_wait(pthread_barrier_t *)
