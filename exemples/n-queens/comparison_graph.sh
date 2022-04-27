#!/bin/bash

folders="
cyp_heuristic_mono
cyp_heuristic_actor
"

for d in ${folders}; do
   cd ${d}
   echo "============================================================================"
   ./launcher.py params2.toml result.json
   cd ..
done

cd cyp_heuristic_actor
./graph.py
./graph_comparison.py
cd ..
cd cyp_heuristic_mono
./graph.py
cd ..
