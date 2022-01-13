# Golomb

Compute Golomb sequence up to 50 (without memoize). Benchmark.

- very few calculations
- a lot of recursivity

    ./make_all.sh
    ./launch_all.sh

Expected results

    ./launch_all.sh
    ============================================================================
    Golomb, pure python
    params: [50]
    duration: 44.074s

    ============================================================================
    Golomb, cython naive (original pure python used as cython source)
    params: [50]
    duration: 8.542s

    ============================================================================
    Golomb, cython using python syntax
    params: [50]
    duration: 8.532s

    ============================================================================
    Golomb, cython monocore
    params: [50]
    duration: 0.619s

    ============================================================================
    Golomb, cython multicore, using prange
    params: [50]
    duration: 0.465s

    ============================================================================
    Golomb, cythonplus monocore, implementation with internal method
    params: [50]
    duration: 0.488s

    ============================================================================
    Golomb, cythonplus monocore, implementation with ouside function
    params: [50]
    duration: 0.619s

    ============================================================================
    Golomb, cythonplus multicore, 'with wlocked' implementation
    params: [50]
    duration: 0.239s

    ============================================================================
    Golomb, cythonplus multicore, implementation with actors
    params: [50]
    duration: 0.215s

    ============================================================================
    Golomb, cythonplus multicore, implementation with actors, with instance method
    params: [50]
    duration: 0.164s

    ============================================================================
    Golomb, cythonplus multicore, implementation with actors, with instance method, reverse order
    params: [50]
    duration: 0.137s
