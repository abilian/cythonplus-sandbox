#!/bin/bash

[ -f fannkuchredux.c ] && rm -f fannkuchredux.c
python setup.py build_ext --inplace
