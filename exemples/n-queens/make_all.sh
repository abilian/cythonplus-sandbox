#!/bin/bash

folders="
cyp_basic_dfs
cyp_adv_dfs
"

for d in ${folders}; do
   cd ${d}
   echo "============================================================================"
   echo $echo $PWD
   echo $echo
   ./make.sh
   cd ..
done
