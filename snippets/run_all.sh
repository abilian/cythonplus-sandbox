#!/bin/bash

folders="
helloworld
localtime_wrapper
"

for d in ${folders}; do
   cd ${d}
   echo "========= run '${d}'"
   ./run.sh
   cd ..
done
