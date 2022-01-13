#!/bin/bash

[ -f golomb_pysyn.c ] && rm -f golomb_pysyn.c
python setup.py build_ext --inplace
