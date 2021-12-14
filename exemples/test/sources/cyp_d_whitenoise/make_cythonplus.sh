#!/bin/bash

NAME="cyp_d_whitenoise"
[ -f "make_cythonplus.sh" ] || exit 1  # security

. make_libfmt.sh

# [ -d build ] && rm -fr build
mkdir -p build
rsync -a libfmt build/
rsync -a ${NAME} build/

cp setup.py build
cd build

python setup.py build_ext --inplace
tree ${NAME}
python -c "import ${NAME}; \
           print(${NAME}, 'version', ${NAME}.__version__)"
cd ..
