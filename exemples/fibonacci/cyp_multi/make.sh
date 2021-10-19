#!/bin/bash

[ -f fibonacci_cyp_multi.cpp ] && rm -f fibonacci_cyp_multi.cpp
rm -f *.so

python setup.py build_ext --inplace
