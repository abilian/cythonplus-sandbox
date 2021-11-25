#!/bin/bash -v

[ -f "build_cyp_c_whitenoise.sh" ] || exit 1
[ -d build_cyp_c_whitenoise ] && rm -fr build_cyp_c_whitenoise
cd sources/cyp_c_whitenoise
./make_cythonplus.sh
cd ../..
mv sources/cyp_c_whitenoise/build/cyp_c_whitenoise .
