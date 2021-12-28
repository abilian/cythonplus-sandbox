#!/bin/bash
echo "Build all, bench all"

# script to be run from this folder:
[[ -f all_build_bench.sh ]] || exit 1

./build_gu_wn_python.sh
./build_actor_static_server.sh

./bench_gu_wn_python.sh
./bench_actor_static_server.sh
