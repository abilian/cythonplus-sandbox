#!/bin/bash

[ -f test_containerlib_full.sh ] || exit 1

# for MacOS environment, need to select some gcc compiler:
[[ "$OSTYPE" == "darwin"* ]] && source ../../../utils/gcc_macports_alias.sh

echo "1) clean"
source clean_files.sh

echo "2) copy files"
source copy_files.sh

echo "3) Compile containerlib"
python setup_containerlib.py build_ext --inplace
echo "---------------------------------------------------"

echo "4) Compile test suite"
python setup_all_tests.py build_ext --inplace
echo "---------------------------------------------------"
echo "5) Run test suite"
python -m unittest unit_test_all.py
