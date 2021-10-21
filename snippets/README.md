# Snippets of Cython+ code

This folder contains short snippets of code showing howto to use the Cython+ compiler.


## Organization

Each subfolder contains a complete exemple and the following files:

- make.sh: script to build the exemple
- run.sh: script to demonstrate the compiled code

The `lib`folder contains various common libraries used by several exemples.

## Requirements

*(to be completed)*

- gcc compiler with the folowing libraries:
  - cython+ compiler
  - c++ STL
  - libfmt


## List of snippets

- helloworld

  A basic "Hellow World" exemple using `cypclass`.

  tags: `basic`, `cypclass`

- localtime_wrapper

  A wrapper around the libc `time` library, with both cython+ and python helper function to display current local time. Note that cython+ strings are plain b"" strings that need to be decoded to UTF-8 to be used as regular python `str`.

    tags: `libc`, `pxd`, `string`, `nogil`


## Licence

*(to be completed, maybe some CC-by for this demo code?)*
