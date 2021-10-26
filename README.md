# cythonplus-sandbox

This repository contains code experiments in cython plus, at different maturity levels

- `exemples/`

  experiments, trial and error, (including benchmarks tests).
  The results are intended to be moved over time to more structured folders (libraries,
  snippets, use case)


- `libs/`

  A set of tested libraries, used in `exemples` and/or `snippets`.
  (Today mostly the container lib, but schedulers variants, posix APIs,
  python-like APIs are candidates to be stored here)


- `snippets/`

  A proposal, both as organization and content, for a collection of code snippets.
  The target is about ~50 code samples, making it possible to understand the main
  aspects of development with cython+ and serving
  as examples of good practice. This could simplify the writing of documentation.
  Snippets could also contain a section with more elaborate code (benchmarks, use cases, ...).


- `utils/`

  Some utilities (notably a script to compile with `gcc` on MacOS using `Macports`).
