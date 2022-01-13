#!/bin/bash

folders="
py_monocore
py_multiprocess
cy_naive_monocore
cy_py_syntax_monocore
cy_multiprocess
cyp_actor
cpp_openmp
c_fastest_openmp
"

for d in ${folders}; do
   cd ${d}
   echo "============================================================================"
   ./launcher.py
   cd ..
done
