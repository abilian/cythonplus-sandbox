#ifndef PTHREAD_BARRIER_H
#define PTHREAD_BARRIER_H
#include <pthread.h>
#define PTHREAD_BARRIER_SERIAL_THREAD 1

typedef struct {
	pthread_mutex_t mutex;
	pthread_cond_t cond;
	int canary;
	int threshold;
} pthread_barrier_t;

typedef struct {} pthread_barrierattr_t;

int pthread_barrier_init(pthread_barrier_t* barrier, const pthread_barrierattr_t* attr, unsigned count);
int pthread_barrier_destroy(pthread_barrier_t* barrier);
int pthread_barrier_wait(pthread_barrier_t* barrier);

#endif
