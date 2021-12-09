#!/bin/bash

NAME="cyp_f_whitenoise"
[ -f "make_cythonplus.sh" ] || exit 1  # security

. make_libfmt.sh

[ -d build ] && rm -fr build
mkdir -p build
cp -a libfmt build
cp -a ${NAME} build

cp setup_test_scan.py build
cd build

python setup_test_scan.py build_ext --inplace
find ${NAME} -type f -name "*.c" -delete
find ${NAME} -type f -name "*.cpp" -delete
find ${NAME} -type f -name "*.py" ! -name "__init__.py" -delete
rm -fr ${NAME}/__pycache__

echo "-----------------------------------------------------------"
python -c "import ${NAME}; \
           print(${NAME}, 'version', ${NAME}.__version__)"
python -c "from ${NAME} import test_scan as t; t.main()"

cd ..
