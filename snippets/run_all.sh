#!/bin/bash

source _folders.sh

for d in ${folders}; do
   cd ${d}
   echo "========= run '${d}'"
   ./run.sh
   cd ..
done
