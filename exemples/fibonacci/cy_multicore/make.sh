#!/bin/bash

[ -f fibonacci_cy_multicore.c ] && rm -f fibonacci_cy_multicore.c

# for MacOS environment, need to select some gcc compiler (macport only...):
[[ "$OSTYPE" == "darwin"* ]] && source ../../../utils/gcc_macports_alias.sh

python setup.py build_ext --inplace
