#!/bin/bash

[ -f n_queens_adv_heuristic.cpp ] && rm -f n_queens_adv_heuristic.cpp
python setup.py build_ext --inplace
