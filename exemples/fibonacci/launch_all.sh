#!/bin/bash

folders="
py
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
   ./launcher.py
   cd ..
done
