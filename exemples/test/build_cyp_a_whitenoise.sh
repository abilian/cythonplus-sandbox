#!/bin/bash -v

[ -f "build_cyp_a_whitenoise.sh" ] || exit 1
[ -d cyp_a_whitenoise ] && rm -fr cyp_a_whitenoise
cd sources/cyp_a_whitenoise
./make_cythonplus.sh
cd ../..
mv sources/cyp_a_whitenoise/build/cyp_a_whitenoise .
