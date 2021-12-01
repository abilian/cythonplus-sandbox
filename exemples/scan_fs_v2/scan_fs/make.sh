#!/bin/bash

[ -f make.sh ] || exit 1

. make_libfmt.sh

[ -d build ] && rm -fr build
rm -f *.cpp
rm -f *.so

python setup.py build_ext --inplace
