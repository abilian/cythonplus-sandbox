#!/bin/bash

[ -f "make_cythonplus.sh" ] || exit 1  # security

[ -d build ] && rm -fr build
mkdir build
cp -a cyp_a_whitenoise build
cp setup.py build
cd build
python setup.py build_ext --inplace
find cyp_a_whitenoise -type f -name "*.c" -delete
find cyp_a_whitenoise -type f -name "*.cpp" -delete
find cyp_a_whitenoise -type f -name "*.py" ! -name "__init__.py" -delete
rm -fr cyp_a_whitenoise/__pycache__
tree cyp_a_whitenoise
python -c "import cyp_a_whitenoise; \
           print(cyp_a_whitenoise, 'version', cyp_a_whitenoise.__version__)"
cd ..
