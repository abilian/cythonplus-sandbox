#!/bin/bash

folders="
cy_monocore
cy_multicore
cyp_monocore
cyp_multi
cyp_multi_optim
"

for d in ${folders}; do
   cd ${d}
   echo "============================================================================"
   echo $echo $PWD
   echo $echo
   ./make.sh
   cd ..
done
