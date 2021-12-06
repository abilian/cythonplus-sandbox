#!/bin/bash

NAME="cyp_dumb_whitenoise"
[ -f "make_cythonplus.sh" ] || exit 1  # security

. make_libfmt.sh

[ -d build ] && rm -fr build
mkdir build
cp -a libfmt build
cp -a ${NAME} build

cp setup.py build
cd build

python setup.py build_ext --inplace
find ${NAME} -type f -name "*.c" -delete
find ${NAME} -type f -name "*.cpp" -delete
find ${NAME} -type f -name "*.py" ! -name "__init__.py" -delete
rm -fr ${NAME}/__pycache__
tree ${NAME}
python -c "import ${NAME}; \
           print(${NAME}, 'version', ${NAME}.__version__)"
cd ..
