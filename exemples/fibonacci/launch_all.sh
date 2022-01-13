#!/bin/bash

folders="
python_pure
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
   ./launcher.py
   cd ..
done
