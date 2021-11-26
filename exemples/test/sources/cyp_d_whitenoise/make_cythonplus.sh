#!/bin/bash

NAME="cyp_d_whitenoise"
[ -f "make_cythonplus.sh" ] || exit 1  # security

[ -d build ] && rm -fr build
mkdir build
cp -a ${NAME} build
cp setup.py build
cp gcc_macports_alias.sh build
cd build

# for MacOS environment using MacPorts, need to select some gcc compiler:
# required for c++17:
[[ "$OSTYPE" == "darwin"* ]] && source ./gcc_macports_alias.sh

python setup.py build_ext --inplace
find ${NAME} -type f -name "*.c" -delete
find ${NAME} -type f -name "*.cpp" -delete
find ${NAME} -type f -name "*.py" ! -name "__init__.py" -delete
rm -fr ${NAME}/__pycache__
tree ${NAME}
python -c "import ${NAME}; \
           print(${NAME}, 'version', ${NAME}.__version__)"
cd ..
