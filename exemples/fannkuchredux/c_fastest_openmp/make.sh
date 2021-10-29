#!/bin/bash

cp -f fannkuchredux.gcc-5.gcc fannkuchredux.c
/usr/bin/gcc -pipe -Wall -O3 -fomit-frame-pointer -fopenmp fannkuchredux.c -o fannkuchredux.gcc_run
rm -f fannkuchredux.c
