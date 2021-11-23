#!/bin/bash

[ -f make.sh ] || exit 1
[ -d build ] && rm -fr build
[ -f golomb.cpp ] && rm -f golomb.cpp
rm -f *.so

# for MacOS environment, need to select some gcc compiler:
[[ "$OSTYPE" == "darwin"* ]] && source ../../../utils/gcc_macports_alias.sh

python setup.py build_ext --inplace
