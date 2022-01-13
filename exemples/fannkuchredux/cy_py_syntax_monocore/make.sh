#!/bin/bash

[ -f fannkuchredux_pysyn.c ] && rm -f fannkuchredux_pysyn.c
python setup.py build_ext --inplace
