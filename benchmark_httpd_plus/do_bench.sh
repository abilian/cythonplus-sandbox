#!/bin/bash
echo "Bench all"

# script to be run from this folder:
[[ -f do_bench.sh ]] || exit 1

for bench in bench_scripts/*.sh
do
    echo "========================================================================="
    if [[ ${bench} =~ .*/_.* ]]
    then
        echo "pass '${bench}'"
    else
        echo ${bench}
        ./${bench}
    fi
done
