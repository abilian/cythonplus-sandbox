#!/bin/bash -v

[ -f "build_cyp_d_whitenoise.sh" ] || exit 1
[ -d cyp_d_whitenoise ] && rm -fr cyp_d_whitenoise
cd sources/cyp_d_whitenoise
./make_cythonplus.sh
cd ../..
mv sources/cyp_d_whitenoise/build/cyp_d_whitenoise .
