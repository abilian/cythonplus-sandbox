#!/bin/bash

echo "MAC ONLY"
echo

[ -f test.cpp ] && rm -f test.cpp

# for MacOS environment, need to select some gcc compiler (macport only...):
[[ "$OSTYPE" == "darwin"* ]] && source ../../utils/gcc_macports_alias.sh


python setup.py build_ext --inplace
