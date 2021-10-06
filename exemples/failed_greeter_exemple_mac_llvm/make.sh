#!/bin/bash

echo "MAC ONLY"
[[ "$OSTYPE" == "darwin"* ]] || exit 1
echo

[ -f test.cpp ] && rm -f test.cpp

cd lib_barrier
clang -dynamiclib -o libpthread_barrier.dylib pthread_barrier.c
cd ..

# for MacOS environment, need to select some gcc compiler (macport only...):
shopt -s expand_aliases
source ../../utils/gcc_macports_alias.sh

CFLAGS="-Ilib_barrier"
LDFLAGS="-Llib_barrier"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:lib_barrier

python setup.py build_ext --inplace
