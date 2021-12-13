#!/bin/bash

NAME="split"
[ -f "make_split.sh" ] || exit 1  # security

. make_libfmt.sh

# [ -d build ] && rm -fr build
mkdir -p build
rsync -a libfmt build/
rsync -a ${NAME} build/

cp setup_split.py build
cd build

python setup_split.py build_ext --inplace
# find ${NAME} -type f -name "*.c" -delete
# find ${NAME} -type f -name "*.cpp" -delete
# find ${NAME} -type f -name "*.py" ! -name "__init__.py" -delete
rm -fr ${NAME}/__pycache__

echo "-----------------------------------------------------------"
python -c "import ${NAME}; \
           print(${NAME}, 'version', ${NAME}.__version__)"
python -c "from ${NAME} import test_split as t; t.main()"

cd ..
