#!/bin/bash -v

[ -f "build_cywhitenoise.sh" ] || exit 1
[ -d cywhitenoise ] && rm -fr cywhitenoise
cd sources/cywhitenoise
./make_cython.sh
cd ../..
mv sources/cywhitenoise/build/cywhitenoise .
