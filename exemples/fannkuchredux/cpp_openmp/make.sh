#!/bin/bash

cp -f fannkuchredux.gpp-5.gpp fannkuchredux.c++
/usr/bin/g++ -c -pipe -O3 -fomit-frame-pointer -std=c++11 -fopenmp fannkuchredux.c++ -o fannkuchredux.c++.o &&  \
        /usr/bin/g++ fannkuchredux.c++.o -o fannkuchredux.gcc_run -fopenmp
rm -f fannkuchredux.c++
rm -f fannkuchredux.c++.o
