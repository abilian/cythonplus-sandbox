#!/bin/bash

[ -f problem.cpp ] && rm -f problem.cpp
rm -f *.so

python setup.py build_ext --inplace
