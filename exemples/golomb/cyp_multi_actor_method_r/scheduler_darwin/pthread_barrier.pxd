cdef extern from "c_pthread_barrier.h" nogil:
    ctypedef union pthread_barrier_t:
        pass
    ctypedef union pthread_barrierattr_t:
        pass

    int pthread_barrier_init(pthread_barrier_t *, const pthread_barrierattr_t *, unsigned int)
    int pthread_barrier_destroy(pthread_barrier_t *)
    int pthread_barrier_wait(pthread_barrier_t *)
