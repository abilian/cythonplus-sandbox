#!/bin/bash

[ -f fibonacci_cyplus_monocore.cpp ] && rm -f fibonacci_cyplus_monocore.cpp

# for MacOS environment, need to select some gcc compiler (macport only...):
[[ "$OSTYPE" == "darwin"* ]] && source ../../../utils/gcc_macports_alias.sh

python setup.py build_ext --inplace
