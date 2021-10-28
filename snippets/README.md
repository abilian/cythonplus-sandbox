# Snippets of Cython+ code

This folder contains short snippets of code showing howto to use the Cython+ compiler.


## Content

Each subfolder contains a complete example and the following files:

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

  tags: `basic`, `cypclass`, `printf`


- cyplist_basic

  A basic use case of `cyplist`, the list class of cython+.

  tags: `basic`, `printf`, `cyplist`, `int`


- cypdict_basic

  A basic use case of `cypdict`, the dict class of cython+.

  tags: `basic`, `printf`, `cypdict`, `string`, `long`


- cypset_basic

  A basic use case of `cypset`, the set class of cython+.

  tags: `basic`, `printf`, `cypset`, `long`


- list_sort_reverse_in_place

  A quick implementation of in-place sort and reverse of a list.

  tags: `list`, `sort`, `reverse`


- list_copy_slice

  A quick implementation of copy slice of a list.

  tags: `list`, `slice`


- numeric limits

  Display the size of main numeric types. Cython+ relies on C++ types, whose size
  can vary by operating system or compiler.

  tags: `numeric`, `types`, `cypclass`, `inheritance`


- localtime_wrapper

  A wrapper around the libc `time` library, with both cython+ and python helper
  function to display current local time. Note that cython+ strings are plain b""
  strings that need to be decoded to UTF-8 to be used as regular python `str`.

    tags: `libc`, `pxd`, `string`


- factorial

   A factorial() implementation. Note that cython+ does not use unlimited size
   integers, so the possibility of an overflow need to be checked.

    tags: `unsigned long long`, `overflow`


## Licence

*(to be completed, maybe some CC-by for this demo code?)*
