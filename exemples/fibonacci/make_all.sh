#!/bin/bash

folders="
cy_naive
cy_python_syntax
cy_monocore
cy_multicore
cyp_monocore
cyp_multi
cyp_multi_optim
cyp_multi_optim_actor
"

for d in ${folders}; do
   cd ${d}
   echo "============================================================================"
   echo $echo $PWD
   echo $echo
   ./make.sh
   cd ..
done
