#!/bin/bash

echo "MAC ONLY"
[[ "$OSTYPE" == "darwin"* ]] || exit 1
echo

[ -f test.cpp ] && rm -f test.cpp

# for MacOS environment, need to select some gcc compiler (macport only...):
shopt -s expand_aliases
source ../../utils/gcc_macports_alias.sh

cd lib_barrier
# gcc -shared -pthread -c mac_pthread_barrier.c -o mac_pthread_barrier.o
gcc -shared -fPIC -pthread -c pthread_barrier.c -o pthread_barrier.o
ar rcs pthread_barrier.a pthread_barrier.o
gcc -dynamiclib pthread_barrier.o -o pthread_barrier.dylib

cd ..

CFLAGS="-Ilib_barrier"
LDFLAGS="-Llib_barrier"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:lib_barrier

python setup.py build_ext --inplace
