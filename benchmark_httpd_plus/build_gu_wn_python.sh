#!/bin/bash

S="gu_wn_python"
[ -f "build_${S}.sh" ] || exit 1

. constants.sh

ORIG="$PWD"
[[ -d "src/${S}" ]] || exit 1
[[ -d "bin/${S}" ]] && rm -fr ${S}
mkdir -p bin

cp -a "src/${S}" bin/
