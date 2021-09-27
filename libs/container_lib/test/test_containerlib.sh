#!/bin/bash

[ -f test_containerlib.sh ] || exit 1

full_test=false

# for MacOS environment, need to select some gcc compiler:
[[ "$OSTYPE" == "darwin"* ]] && source ../../../utils/gcc_macports_alias.sh

${full_test} && {

echo "1) clean"
./clean_files.sh

echo "2) copy files"
cp -a ../containerlib .
cp -a ../stdlib .
files="
extension_any_scalar_dict.py
extension_any_scalar_list.py
extension_any_scalar.py
extension_scalar_dicts.py
setup_containerlib.py
"
for f in ${files}; do
    cp -f ../${f} .
done

echo "3) Compile containerlib"
python setup_containerlib.py build_ext --inplace
echo "---------------------------------------------------"

} # /full test

echo "4) Compile test suite"
python setup_all_tests.py build_ext --inplace
echo "---------------------------------------------------"
echo "4) Run test suite"
python -m unittest unit_test_all.py
