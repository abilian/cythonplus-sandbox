#!/bin/bash
NAME="cypxmlactor"
[ -f "make.sh" ] || exit 1  # security

. make_libfmt.sh

[[ -d build/${NAME} ]] && find build/${NAME} -name "*.so" -delete
mkdir -p build
rsync -a libfmt build/
rsync -a ${NAME} build/

cp setup.py build
cd build

python setup.py build_ext --inplace
cd ..

./test.sh

# mkdir -p bin
# rsync -a build/"${S}" bin/
