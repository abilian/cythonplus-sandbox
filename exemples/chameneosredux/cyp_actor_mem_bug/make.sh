#!/bin/bash

[ -f chameneos.cpp ] && rm -f chameneos.cpp
rm -f *.so

python setup.py build_ext --inplace
