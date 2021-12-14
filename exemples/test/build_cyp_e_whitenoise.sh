#!/bin/bash -v

S="cyp_e"
[ -f "build_${S}_whitenoise.sh" ] || exit 1
[ -d ${S}_whitenoise ] && rm -fr ${S}_whitenoise
cd sources/${S}_whitenoise
./make_cythonplus.sh
cd ../..
rsync -a sources/${S}_whitenoise/build/${S}_whitenoise .
