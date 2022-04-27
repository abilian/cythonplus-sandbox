#!/bin/bash

folders="
py_basic_dfs
cyp_basic_dfs
py_adv_dfs
cyp_adv_dfs
py_heuristic
cyp_heuristic_mono
cyp_heuristic_actor
"

for d in ${folders}; do
   cd ${d}
   echo "============================================================================"
   ./launcher.py params.toml stdout
   cd ..
done
