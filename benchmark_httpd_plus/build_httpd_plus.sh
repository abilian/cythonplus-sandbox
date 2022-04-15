#!/bin/bash -v

[ -f "build_httpd_plus.sh" ] || exit 1

. constants.sh

ORIG="$PWD"

[[ -d bin/httpd_plus ]] && rm -fr bin/httpd_plus
mkdir -p bin

[[ -d httpd-plus ]] || git clone https://github.com/abilian/httpd-plus
cd httpd-plus
git pull
./make_httpd_plus.sh

cd "${ORIG}"
cp -a httpd-plus/bin/httpd_plus bin/
