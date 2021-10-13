#!/bin/bash

[ -f fibonacci_cyplus_multicore.cpp ] && rm -f fibonacci_cyplus_multicore.cpp
rm -f *.so

python setup.py build_ext --inplace
