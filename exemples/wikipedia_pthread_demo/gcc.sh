#!/bin/bash
shopt -s expand_aliases

alias gcc='gcc-mp-10'
alias cc='gcc-mp-10'
alias g++='g++-mp-10'
alias c++='g++-mp-10'

export CC=/opt/local/bin/gcc-mp-10
export CXX=/opt/local/bin/g++-mp-10
export CPP=/opt/local/bin/g++-mp-10
export LD=/opt/local/bin/g-mp-10

gcc --version
[ -f pthreads_demo ] && rm pthreads_demo
gcc pthreads_demo.c -pthread -o pthreads_demo
./pthreads_demo
