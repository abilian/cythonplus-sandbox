#!/bin/bash -v

S="actor_static_server"
[ -f "build_${S}.sh" ] || exit 1

. constants.sh

ORIG="$PWD"
[[ -d "src/${S}" ]] || exit 1
[[ -d "bin/${S}" ]] && rm -fr ${S}
mkdir -p bin

cd "src/${S}"
./make_cythonplus.sh
cd "${ORIG}"
rsync -a src/"${S}"/build/"${S}" bin/
