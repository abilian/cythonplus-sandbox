#!/bin/bash

[ -f test_containerlib_full.sh ] || exit 1

# for MacOS environment, need to select some gcc compiler:
[[ "$OSTYPE" == "darwin"* ]] && source ../../../utils/gcc_macports_alias.sh

python setup_all_tests.py build_ext --inplace
echo "---------------------------------------------------"
python -m unittest unit_test_all.py
