#!/bin/bash
[ -f fibonacci_cy_monocore.c ] && rm -f fibonacci_cy_monocore.c
python setup.py build_ext --inplace
