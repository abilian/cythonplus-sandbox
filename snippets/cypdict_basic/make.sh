#!/bin/bash

# minimal security:
[ -f "make.sh" ] || exit 1

# copy of required cython+ libs:
required="
stdlib
"
for lib_dir in ${required}; do
    cp -a ../common_libs/${lib_dir} .
done

# for MacOS environment using MacPorts, need to select some gcc compiler:
[[ "$OSTYPE" == "darwin"* ]] && source ../utils/gcc_macports_alias.sh

python setup.py build_ext --inplace
