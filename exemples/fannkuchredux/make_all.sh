#!/bin/bash

folders="
cy_multiprocess
cyp_actor
cpp_openmp
c_fastest_openmp
"

for d in ${folders}; do
   cd ${d}
   echo "============================================================================"
   echo $echo $PWD
   echo $echo
   ./make.sh
   cd ..
done
