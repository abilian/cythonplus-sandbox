#!/bin/bash -v

[ -f "build_cyp_e_whitenoise.sh" ] || exit 1
[ -d cyp_e_whitenoise ] && rm -fr cyp_e_whitenoise
cd sources/cyp_e_whitenoise
./make_cythonplus.sh
cd ../..
mv sources/cyp_e_whitenoise/build/cyp_e_whitenoise .
