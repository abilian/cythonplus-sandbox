#!/bin/bash -v

S="server"
[ -f "build_${S}.sh" ] || exit 1
[ -d ${S} ] && rm -fr ${S}
cd sources/${S}
./make_cythonplus.sh
cd ../..
rsync -a sources/${S}/build/${S} .
