#!/bin/bash

folders="
py_multicore
cyp_actor_v2
"

for d in ${folders}; do
   cd ${d}
   echo "============================================================================"
   ./launcher.py
   cd ..
done
