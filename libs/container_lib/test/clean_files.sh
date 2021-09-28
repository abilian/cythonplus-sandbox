#!/bin/bash

[ -f test_containerlib_full.sh ] || exit 1   # security

rm -fr build
rm -fr __pycache__
rm -f *.so
rm -f *.cpp
rm -f */*.so
rm -f */*.cpp

rm -fr containerlib
rm -fr stdlib
rm -f extension_any_scalar_dict.py
rm -f extension_any_scalar_list.py
rm -f extension_any_scalar.py
rm -f extension_scalar_dicts.py
rm -f setup_containerlib.py
