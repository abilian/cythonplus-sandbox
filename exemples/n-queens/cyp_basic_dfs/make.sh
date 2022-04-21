#!/bin/bash

[ -f n_queens_basic_dfs.cpp ] && rm -f n_queens_basic_dfs.cpp
python setup.py build_ext --inplace
