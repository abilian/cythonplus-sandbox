#!/bin/bash

folders="
py_basic_dfs
cyp_basic_dfs
py_adv_dfs
cyp_adv_dfs
py_adv_heuristic
"

for d in ${folders}; do
   cd ${d}
   echo "============================================================================"
   ./launcher.py
   cd ..
done
