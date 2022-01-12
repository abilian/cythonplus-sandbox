#!/bin/bash
echo "Build all, bench all"

# script to be run from this folder:
[[ -f all_build_bench.sh ]] || exit 1

./build_gu_wn_python.sh
./build_httpd_plus.sh
./do_bench.sh
