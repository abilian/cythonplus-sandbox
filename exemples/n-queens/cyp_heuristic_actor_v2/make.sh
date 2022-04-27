#!/bin/bash

[ -f n_queens_adv_heuristic_actor_v2.cpp ] && rm -f n_queens_adv_heuristic_actor_v2.cpp
python setup.py build_ext --inplace
