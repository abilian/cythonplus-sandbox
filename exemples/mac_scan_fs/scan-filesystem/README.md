# A Comparison program between Cython+, Python and Rust

As a way to write a Cython+ program under real conditions, we ported an existing small program already written in Python and Rust to Cython+.

The program was chosen because it is short and because it is very conducive to parallel execution, allowing us to try out Cython+'s approach to concurrent programming.

## What it does

The program in question scans a filesystem from the root down (without following symbolic links) and:
- stores the results of a `stat` system call for each directory, file and symbolic link,
- computes messages digests from each file using `md5`, `sha1`, `sh256` and `sha512` algorithms,
- stores the target path of each symbolic link,

A JSON representation of the gathered information is then dumped in a file.

As Cython+ lacks an argument parser, the root directory is hardcoded as `/` and the output file as `result.json`.

The Python and Rust programs originally were making use of an argument parser, gathering additional information, and then uploading the result online, but they were simplified to match the description above because Cython+ currently lacks a good standard library, substantially increasing the required development work for even seemingly basic tasks.


## Building the Cython+ version

### Dependencies:

The program works on linux with Python3.7 and depends on the following:

- openssl library
- [fmt library](https://fmt.dev/latest/index.html)
- python3.7 development headers, which depending on the distribution may be packaged separately from python itself
- [Nexedi's cython+ compiler](https://lab.nexedi.com/nexedi/cython)

The paths to the openssl and fmt libraries should be updated in `cython/Makefile` and `cython/setup.py`.
The path to the python development headers shoudl be updated in `cython/Makefile`.
The path to the cython+ compiler should be added to environment variable `PYTHONPATH`.


### Building

First go to the cython subdirectory:

```
$ cd cython/
```

To build:

```
$ make
```

Or equivalently: `python3 setup.py build_ext --inplace`

To run:

```
$ make run
```


### Building without the Python runtime

The Cython compiler systematically links compiled programs against the python runtime, however this program never actually calls into the Python runtime.

There is no support yet in the Cython+ language to express independance from the Python runtime and generate code which does not need to include the Python headers. However in the meantime we introduce a hack: we only use the cython compiler to generate a C++ file which we then compile and link manually, but instead of providing the python runtime to link against we tell the linker to ignore linking errors. We also provide a `main` function as an entry point to bypass the entry point for the python interpreter.

This hack can only work because this program happens not to require the python runtime for anything.
No guarantees whatsoever are made that the program produced will behave as expected.
It has been tested and shown to work with g++.

To build:

```
$ make nopython
```

To run:

```
$ make runnopython
```
