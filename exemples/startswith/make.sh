#!/bin/bash

NAME="test_startswith.pyx"

[ -f "make.sh" ] || exit 1  # security

# for MacOS environment, need to select some recent gcc compiler:
[[ "$OSTYPE" == "darwin"* ]] && source ./gcc_macports_alias.sh

[ -d build ] && rm -fr build
mkdir build
cp -a stdlib build
cp -a startswith.* build
cp ${NAME} build
cp setup.py build

cd build
python setup.py build_ext --inplace
cd ..
find build -name ${NAME%.pyx}*.so -exec cp -f "{}" . \;
find build -name startswith.*so -exec cp -f "{}" . \;
