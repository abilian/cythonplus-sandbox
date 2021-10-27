#!/bin/bash

folders="
py_monocore
py_multiprocess
cy_multiprocess
"

for d in ${folders}; do
   cd ${d}
   echo "============================================================================"
   ./launcher.py
   cd ..
done
