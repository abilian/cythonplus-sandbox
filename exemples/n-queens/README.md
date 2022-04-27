# N-queens

## Search one solution to the N-queens problem. Benchmark.

2 families of algorithms:

-   Depth-first search, with backtracking: slow, lot of recursion,
-   heuristic with progressive improvements and randomness: fast, not 100% safe.


## Comments on results

**DFS**

-   The basic DFS stores the position of the board in a list of lists of boxes.
    The tests are done by reading the contents of the board. It's not effective.
-   Advanced DFS only stores queens coordinates (in a one-dimensional single list).
    The tests are performed by calculating integer divisions and modulos.

But Python is slow on calculations and fast on accessing lists. So the results:

-   Basic DFS, Python: 0.838s
-   Advanced DFS, Python: 2.758s, slower then basic!

Then using Cython+, the calculations are done in C++:

-   Basic DFS, Cython+ single-core: 0.299s (speed/python almost x3)
-   Advanced DFS, Cython+ single-core: 0.086s, faster than basic, (speed/python almost x10)

However, DFS is not possible for large map sizes: by changing the map size from
18 to 28, the result goes from 0.086s to 14.100s. And this algorithm is not suitable
for parallelization.

**Heuristic**

On a large board, using custom heuristics (gradually improving queens placement with
some randomness), board size of 250x250:

-   Python: 52.873s
-   Cython+ single-core: 2.014s
-   Cython+ with parallel actors: 2.166s

The implementation with actors is slower, the additional cost of actors is not
compensated by the parallelization gains.

When using a board size of 1000x1000, actors become faster than single-core computation:
-   Cython+ single-core: 32.572s
-   Cython+ with parallel actors: 13.349s

For bigger boards:

-   Time complexity (from data log & linear regression):
    - single-core ~ O(n^2.93)

      ![complexity graph](./cyp_heuristic_mono/reg.png)

    - actors ~ O(n^2.60)

      ![complexity graph](./cyp_heuristic_actor/reg.png)

-   Comparison single-core / actors

  ![comparison graph](./cyp_heuristic_actor/result_comparison.png)

## Expected results:

To proceed:

      ./make_all.sh
      ./launch_all.sh

Results:

    ./launch_all.sh
    ============================================================================
    1/1 - N-queens, basic DFS, pure python
    params: [18]
    solving for size 18:
    * . . . . . . . . . . . . . . . . .
    . . . * . . . . . . . . . . . . . .
    . * . . . . . . . . . . . . . . . .
    . . . . . . . . . . . . . * . . . .
    . . * . . . . . . . . . . . . . . .
    . . . . . . . . . . * . . . . . . .
    . . . . . . . . . . . . * . . . . .
    . . . . * . . . . . . . . . . . . .
    . . . . . . . . . . . . . . . * . .
    . . . . . . . . . . . . . . . . . *
    . . . . . . . . . . . . . . * . . .
    . . . . . . * . . . . . . . . . . .
    . . . . . . . . * . . . . . . . . .
    . . . . . . . . . . . . . . . . * .
    . . . . . * . . . . . . . . . . . .
    . . . . . . . * . . . . . . . . . .
    . . . . . . . . . * . . . . . . . .
    . . . . . . . . . . . * . . . . . .
    duration: 0.838s

    ============================================================================
    1/1 - N-queens, basic DFS, cython+ single-core
    params: [18]
    solving for size 18:
    * . . . . . . . . . . . . . . . . .
    . . . * . . . . . . . . . . . . . .
    . * . . . . . . . . . . . . . . . .
    . . . . . . . . . . . . . * . . . .
    . . * . . . . . . . . . . . . . . .
    . . . . . . . . . . * . . . . . . .
    . . . . . . . . . . . . * . . . . .
    . . . . * . . . . . . . . . . . . .
    . . . . . . . . . . . . . . . * . .
    . . . . . . . . . . . . . . . . . *
    . . . . . . . . . . . . . . * . . .
    . . . . . . * . . . . . . . . . . .
    . . . . . . . . * . . . . . . . . .
    . . . . . . . . . . . . . . . . * .
    . . . . . * . . . . . . . . . . . .
    . . . . . . . * . . . . . . . . . .
    . . . . . . . . . * . . . . . . . .
    . . . . . . . . . . . * . . . . . .
    duration: 0.299s

    ============================================================================
    1/1 - N-queens, advanced DFS, pure python
    params: [18]
    solving for size 18:
    * . . . . . . . . . . . . . . . . .
    . . * . . . . . . . . . . . . . . .
    . . . . * . . . . . . . . . . . . .
    . * . . . . . . . . . . . . . . . .
    . . . . . . . * . . . . . . . . . .
    . . . . . . . . . . . . . . * . . .
    . . . . . . . . . . . * . . . . . .
    . . . . . . . . . . . . . . . * . .
    . . . . . . . . . . . . * . . . . .
    . . . . . . . . . . . . . . . . * .
    . . . . . * . . . . . . . . . . . .
    . . . . . . . . . . . . . . . . . *
    . . . . . . * . . . . . . . . . . .
    . . . * . . . . . . . . . . . . . .
    . . . . . . . . . . * . . . . . . .
    . . . . . . . . * . . . . . . . . .
    . . . . . . . . . . . . . * . . . .
    . . . . . . . . . * . . . . . . . .
    duration: 2.758s

    ============================================================================
    1/2 - N-queens, advanced DFS, cython+ single-core
    params: [18]
    solving for size 18:
    * . . . . . . . . . . . . . . . . .
    . . * . . . . . . . . . . . . . . .
    . . . . * . . . . . . . . . . . . .
    . * . . . . . . . . . . . . . . . .
    . . . . . . . * . . . . . . . . . .
    . . . . . . . . . . . . . . * . . .
    . . . . . . . . . . . * . . . . . .
    . . . . . . . . . . . . . . . * . .
    . . . . . . . . . . . . * . . . . .
    . . . . . . . . . . . . . . . . * .
    . . . . . * . . . . . . . . . . . .
    . . . . . . . . . . . . . . . . . *
    . . . . . . * . . . . . . . . . . .
    . . . * . . . . . . . . . . . . . .
    . . . . . . . . . . * . . . . . . .
    . . . . . . . . * . . . . . . . . .
    . . . . . . . . . . . . . * . . . .
    . . . . . . . . . * . . . . . . . .
    duration: 0.086s

    2/2 - N-queens, advanced DFS, cython+ single-core
    params: [28]
    solving for size 28:
    * . . . . . . . . . . . . . . . . . . . . . . . . . . .
    . . * . . . . . . . . . . . . . . . . . . . . . . . . .
    . . . . * . . . . . . . . . . . . . . . . . . . . . . .
    . * . . . . . . . . . . . . . . . . . . . . . . . . . .
    . . . * . . . . . . . . . . . . . . . . . . . . . . . .
    . . . . . . . . * . . . . . . . . . . . . . . . . . . .
    . . . . . . . . . . * . . . . . . . . . . . . . . . . .
    . . . . . . . . . . . . * . . . . . . . . . . . . . . .
    . . . . . . . . . . . . . . * . . . . . . . . . . . . .
    . . . . . . . . . . . . . . . . * . . . . . . . . . . .
    . . . . . . . . . . . . . . . . . . . . . . * . . . . .
    . . . . . . . . . . . . . . . . . . . . . . . . * . . .
    . . . . . . . . . . . . . . . . . . . . . * . . . . . .
    . . . . . . . . . . . . . . . . . . . . . . . . . . . *
    . . . . . . . . . . . . . . . . . . . . . . . . . * . .
    . . . . . . . . . . . . . . . . . . . . . . . * . . . .
    . . . . . . . . . . . . . . . . . . . . . . . . . . * .
    . . . . . . * . . . . . . . . . . . . . . . . . . . . .
    . . . . . . . . . . . * . . . . . . . . . . . . . . . .
    . . . . . . . . . . . . . . . * . . . . . . . . . . . .
    . . . . . . . . . . . . . . . . . * . . . . . . . . . .
    . . . . . . . * . . . . . . . . . . . . . . . . . . . .
    . . . . . . . . . * . . . . . . . . . . . . . . . . . .
    . . . . . . . . . . . . . * . . . . . . . . . . . . . .
    . . . . . . . . . . . . . . . . . . . * . . . . . . . .
    . . . . . * . . . . . . . . . . . . . . . . . . . . . .
    . . . . . . . . . . . . . . . . . . . . * . . . . . . .
    . . . . . . . . . . . . . . . . . . * . . . . . . . . .
    duration: 14.100s

    ============================================================================
    1/1 - N-queens, heuristic, sum of 5 runs, pure python
    params: [250, 5]
    solving for size 250
    duration for size 250: 9.458s
    solving for size 250
    duration for size 250: 8.616s
    solving for size 250
    duration for size 250: 10.534s
    solving for size 250
    duration for size 250: 9.005s
    solving for size 250
    duration for size 250: 15.260s
    duration: 52.873s

    ============================================================================
    1/2 - N-queens, heuristic, sum of 5 runs, cython+ single-core
    params: [250, 5]
    solving for size 250
    duration for size 250: ~1s
    solving for size 250
    duration for size 250: ~0s
    solving for size 250
    duration for size 250: ~1s
    solving for size 250
    duration for size 250: ~0s
    solving for size 250
    duration for size 250: ~0s
    duration: 2.014s

    2/2 - N-queens, heuristic, sum of 2 runs, cython+ single-core
    params: [1000, 2]
    solving for size 1000
    duration for size 1000: ~16s
    solving for size 1000
    duration for size 1000: ~16s
    duration: 32.572s

    ============================================================================
    1/2 - N-queens, heuristic, sum of 5 runs, cython+ actors
    params: [250, 5]
    solving for size 250
    duration for size 250: ~1s
    solving for size 250
    duration for size 250: ~0s
    solving for size 250
    duration for size 250: ~1s
    solving for size 250
    duration for size 250: ~0s
    solving for size 250
    duration for size 250: ~0s
    duration: 2.166s

    2/2 - N-queens, heuristic, sum of 2 runs, cython+ actors
    params: [1000, 2]
    solving for size 1000
    duration for size 1000: ~7s
    solving for size 1000
    duration for size 1000: ~7s
    duration: 13.349s
