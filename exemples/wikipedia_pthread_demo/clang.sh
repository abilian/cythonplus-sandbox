#!/bin/bash

gcc --version

[ -f pthreads_demo ] && rm pthreads_demo
gcc pthreads_demo.c -pthread -o pthreads_demo
./pthreads_demo
