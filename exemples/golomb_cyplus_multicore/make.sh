#!/bin/bash

[ -f golomb.cpp ] && rm -f golomb.cpp
rm -f *.so

python setup.py build_ext --inplace
