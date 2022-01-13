#!/bin/bash

[ -f fibonacci_cy_pysyn.c ] && rm -f fibonacci_cy_pysyn.c
python setup.py build_ext --inplace
