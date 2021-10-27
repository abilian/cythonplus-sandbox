#!/bin/bash

[ -f fannkuchredux.cpp ] && rm -f fannkuchredux.cpp
python setup.py build_ext --inplace
