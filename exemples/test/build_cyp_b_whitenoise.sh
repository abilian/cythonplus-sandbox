#!/bin/bash -v

[ -f "build_cyp_b_whitenoise.sh" ] || exit 1
[ -d cyp_b_whitenoise ] && rm -fr cyp_b_whitenoise
cd sources/cyp_b_whitenoise
./make_cythonplus.sh
cd ../..
mv sources/cyp_b_whitenoise/build/cyp_b_whitenoise .
