#!/bin/bash

[ -f n_queens_adv_heuristic_actor.cpp ] && rm -f n_queens_adv_heuristic_actor.cpp
python setup.py build_ext --inplace
