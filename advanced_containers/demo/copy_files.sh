#!/bin/bash

[ -f app.py ] || exit 1   # security

cp -a ../containerlib .
cp -a ../stdlib .
files="
extension_any_scalar_dict.py
extension_any_scalar_list.py
extension_any_scalar.py
extension_scalar_dicts.py
extension_version.py
"
for f in ${files}; do
    cp -f ../${f} .
done
