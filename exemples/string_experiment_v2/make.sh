#!/bin/bash -v

. make_libfmt.sh

name="string_exp"

rm -f *.cpp
rm -f *.so

python setup.py build_ext --inplace

python -c "import ${name}; ${name}.main()"
