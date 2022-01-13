#!/bin/bash

[ -f fibonacci.c ] && rm -f fibonacci.c
python setup.py build_ext --inplace
