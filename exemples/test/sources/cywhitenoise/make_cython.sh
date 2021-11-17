#!/bin/bash

[ -f "make_cython.sh" ] || exit 1  # security

[ -d build ] && rm -fr build
mkdir build
cp -a cywhitenoise build
cp setup.py build
cd build
python setup.py build_ext --inplace
find cywhitenoise -type f -name "*.c" -delete
find cywhitenoise -type f -name "*.py" ! -name "__init__.py" -delete
rm -fr cywhitenoise/__pycache__
tree cywhitenoise
python -c "import cywhitenoise; \
           print(cywhitenoise, 'version', cywhitenoise.__version__)"
cd ..
