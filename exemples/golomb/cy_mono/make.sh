#!/bin/bash

[ -f golomb.c ] && rm -f golomb.c
python setup.py build_ext --inplace
