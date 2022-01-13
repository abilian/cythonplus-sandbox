# Fannkuchredux

Adaptation of Fannkuchredux benchmark.

- Remarks:

  - it's a very embarrassingly parallel algorithm, with no difficulty in building
    balanced processes.

  - algorithm is based on permutation of arrays, where C arrays are at their advantage
    and outperform any python list.

  - For the cython+ version, some hand-made list slicing functions where added on top
    of cyplist, to get closer of pure python code. But they are probably too slow and
    ineffective.


- See description [https://benchmarksgame-team.pages.debian.net/benchmarksgame/performance/fannkuchredux.html]

- test is run for:  cpython, cython, cython+, c++, c

- expected output for fannkuchredux(11):

  ```
  556355
  Pfannkuchen(11) = 51
  ```

Build: `./make_all.sh` (requirements: gcc, openmp, threads and cython+).

Run: `./launch_all.sh`

Expected result like:

```
./launch_all.sh
============================================================================
fannkuchredux, pure python, monocore
params: [11]
556355
Pfannkuchen(11) = 51
duration: 195.394s

============================================================================
fannkuchredux, pure python, multicore using multiprocess
params: [11]
556355
Pfannkuchen(11) = 51
duration: 72.784s

============================================================================
fannkuchredux, monocore, cython naive (original pure python used as cython source)
params: [11]
556355
Pfannkuchen(11) = 51
duration: 103.913s

============================================================================
fannkuchredux, monocore, cython using python syntax
params: [11]
556355
Pfannkuchen(11) = 51
duration: 103.731s

============================================================================
fannkuchredux, cython, basic cython port of multiprocess version
params: [11]
556355
Pfannkuchen(11) = 51
duration: 34.589s

============================================================================
fannkuchredux, cythonplus with actors
params: [11]
556355
Pfannkuchen(11) = 51
duration: 86.904s

============================================================================
fannkuchredux, C++ implementation, using openmp
params: [11]
556355
Pfannkuchen(11) = 51
duration: 0.934s

============================================================================
fannkuchredux, fastest C implementation, using openmp
params: [11]
556355
Pfannkuchen(11) = 51
duration: 0.849s
```
