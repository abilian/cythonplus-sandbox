# Fibonacci

Compute Fibonacci sequence (without memoize), on double, upto 1476, 100x.
- few calculations


    ./make_all.sh
    ./launch_all.sh

Expected results

    ./launch_all.sh
    ============================================================================
    Fibonacci x 100, pure python
    params: [1476, 100]
    duration: 11.425s

    ============================================================================
    Fibonacci x 100, cython monocore
    params: [1476, 100]
    duration: 0.193s

    ============================================================================
    Fibonacci x 100, cython multicore using prange
    params: [1476, 100]
    duration: 0.808s

    ============================================================================
    Fibonacci x 100, cythonplus monocore
    params: [1476, 100]
    duration: 0.234s

    ============================================================================
    Fibonacci x 100, cythonplus multicore
    params: [1476, 100]
    duration: 1.386s

    ============================================================================
    Fibonacci x 100, cythonplus multicore, optimized, joined scheduler
    params: [1476, 100]
    duration: 1.363s

    ============================================================================
    Fibonacci x 100, cythonplus multicore, optimized, result as actor
    params: [1476, 100]
    duration: 1.883s
