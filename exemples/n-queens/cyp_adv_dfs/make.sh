#!/bin/bash

[ -f n_queens_adv_dfs.cpp ] && rm -f n_queens_adv_dfs.cpp
python setup.py build_ext --inplace
