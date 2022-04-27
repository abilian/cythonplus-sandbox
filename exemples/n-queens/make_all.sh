#!/bin/bash

folders="
cyp_basic_dfs
cyp_adv_dfs
cyp_heuristic_mono
cyp_heuristic_actor
cyp_heuristic_actor_v2
"

for d in ${folders}; do
   cd ${d}
   echo "============================================================================"
   echo $echo $PWD
   echo $echo
   ./make.sh
   cd ..
done
