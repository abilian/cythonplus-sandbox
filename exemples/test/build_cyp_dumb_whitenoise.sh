#!/bin/bash -v

[ -f "build_cyp_dumb_whitenoise.sh" ] || exit 1
[ -d cyp_dumb_whitenoise ] && rm -fr cyp_dumb_whitenoise
cd sources/cyp_dumb_whitenoise
./make_cythonplus.sh
cd ../..
mv sources/cyp_dumb_whitenoise/build/cyp_dumb_whitenoise .
