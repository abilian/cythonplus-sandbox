#!/bin/bash

[ -f golomb.cpp ] && rm -f golomb.cpp
python setup.py build_ext --inplace
