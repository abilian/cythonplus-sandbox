#!/bin/bash

[ -f fibonacci_cyplus_multi_pers.cpp ] && rm -f fibonacci_cyplus_multi_pers.cpp
rm -f *.so

python setup.py build_ext --inplace
