#!/bin/bash

[ -f make.sh ] || exit 1
[ -d build ] && rm -fr build
find . -name "*.cpp" -delete
find . -name "*.so" -delete

python setup.py build_ext --inplace
