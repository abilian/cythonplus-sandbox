#!/bin/bash -v

[ -f "build_cyp_min_whitenoise.sh" ] || exit 1
[ -d cyp_min_whitenoise ] && rm -fr cyp_min_whitenoise
cd sources/cyp_min_whitenoise
./make_cythonplus.sh
cd ../..
mv sources/cyp_min_whitenoise/build/cyp_min_whitenoise .
