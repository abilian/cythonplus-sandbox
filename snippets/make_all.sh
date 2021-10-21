#!/bin/bash

source _folders.sh

for d in ${folders}; do
   cd ${d}
   echo "============================================================================"
   echo $echo $PWD
   echo $echo
   ./make.sh
   cd ..
done
