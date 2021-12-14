#!/bin/bash -v

S="cyp_g"
[ -f "build_$S_whitenoise.sh" ] || exit 1
[ -d $S_whitenoise ] && rm -fr $S_whitenoise
cd sources/$S_whitenoise
./make_cythonplus.sh
cd ../..
mv sources/$S_whitenoise/build/$S_whitenoise .
