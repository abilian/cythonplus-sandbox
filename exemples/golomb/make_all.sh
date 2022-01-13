#!/bin/bash

folders="
cy_naive
cy_python_syntax
cy_mono
cy_prange
cyp_mono
cyp_mono_other
cyp_multi
cyp_multi_actor
cyp_multi_actor_method
cyp_multi_actor_method_r
"

for d in ${folders}; do
   cd ${d}
   echo "============================================================================"
   echo $echo $PWD
   echo $echo
   ./make.sh
   cd ..
done
