# Golomb

Compute Golomb sequence up to 50 (without memoize).
- very few calculations
- a lot of recursivity

    ./make_all.sh
    ./launch_all.sh

Expected results

    ./launch_all.sh
    ============================================================================
    Golomb, pure python
    params: [50]
    duration: 42.197s

    ============================================================================
    Golomb, cython monocore
    params: [50]
    duration: 0.594s

    ============================================================================
    Golomb, cython multicore, using prange
    params: [50]
    duration: 0.433s

    ============================================================================
    Golomb, cythonplus monocore, implementation with internal method
    params: [50]
    duration: 0.466s

    ============================================================================
    Golomb, cythonplus monocore, implementation with ouside function
    params: [50]
    duration: 0.587s

    ============================================================================
    Golomb, cythonplus multicore, 'with wlocked' implementation
    params: [50]
    duration: 0.233s

    ============================================================================
    Golomb, cythonplus multicore, implementation with actors
    params: [50]
    duration: 0.223s

    ============================================================================
    Golomb, cythonplus multicore, implementation with actors, with instance method
    params: [50]
    duration: 0.170s

    ============================================================================
    Golomb, cythonplus multicore, implementation with actors, with instance method, reverse order
    params: [50]
    duration: 0.136s
