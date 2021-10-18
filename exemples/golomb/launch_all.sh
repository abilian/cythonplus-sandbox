#!/bin/bash

folders="
py
cy_mono
cy_prange
cyp_mono
cyp_mono_other
cyp_multi
cyp_multi_actor
cyp_multi_actor_method
"

for d in ${folders}; do
   cd ${d}
   echo "============================================================================"
   ./launcher.py
   cd ..
done
