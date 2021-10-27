# Fannkuchredux

Adaptation of Fannkuchredux benchmark (WIP)

- See description [https://benchmarksgame-team.pages.debian.net/benchmarksgame/download/fannkuchredux-output.txt]

- expected output for fannkuchredux(7):

  ```
  228
  Pfannkuchen(7) = 16
  ```

Build: `./make_all.sh`

Run: `./run_all.sh`

Expected result like:

```
./launch_all.sh
============================================================================
fannkuchredux, pure python, monocore
params: [10]
73196
Pfannkuchen(10) = 38
duration: 16.438s

============================================================================
fannkuchredux, pure python, multicore using multiprocess
params: [10]
73196
Pfannkuchen(10) = 38
duration: 7.451s

============================================================================
fannkuchredux, cython, basic cython port of multiprocess version
params: [10]
73196
Pfannkuchen(10) = 38
duration: 3.835s
``'
