#!/bin/bash -v

[ -f "build_cyp_f_whitenoise.sh" ] || exit 1
[ -d cyp_f_whitenoise ] && rm -fr cyp_f_whitenoise
cd sources/cyp_f_whitenoise
./make_cythonplus.sh
cd ../..
mv sources/cyp_f_whitenoise/build/cyp_f_whitenoise .
