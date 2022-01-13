# Fibonacci

Compute Fibonacci sequence (without memoize), on double, upto 1476, 100x.

- To build and run all implementations:

        ./make_all.sh
        ./launch_all.sh


- Expected results:

        ./launch_all.sh

        ============================================================================
        Fibonacci x 100, pure python
        params: [1476, 100]
        duration: 11.477s

        ============================================================================
        Fibonacci x 100, cython naive (original pure python used as cython source)
        params: [1476, 100]
        duration: 2.907s

        ============================================================================
        Fibonacci x 100, cython using python syntax
        params: [1476, 100]
        duration: 0.172s

        ============================================================================
        Fibonacci x 100, cython monocore
        params: [1476, 100]
        duration: 0.193s

        ============================================================================
        Fibonacci x 100, cython multicore using prange
        params: [1476, 100]
        duration: 0.792s

        ============================================================================
        Fibonacci x 100, cythonplus monocore
        params: [1476, 100]
        duration: 0.234s

        ============================================================================
        Fibonacci x 100, cythonplus multicore
        params: [1476, 100]
        duration: 1.372s

        ============================================================================
        Fibonacci x 100, cythonplus multicore, optimized, joined scheduler
        params: [1476, 100]
        duration: 1.336s

        ============================================================================
        Fibonacci x 100, cythonplus multicore, optimized, result as actor
        params: [1476, 100]
        duration: 1.856s
