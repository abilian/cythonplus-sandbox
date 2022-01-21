#!/bin/bash

export TRANSONIC_DIR="./tmp"
export TRANSONIC_DEBUG=true
# TRANSONIC_COMPILE_AT_IMPORT
# TRANSONIC_NO_REPLACE
export TRANSONIC_COMPILE_JIT=false
# export TRANSONIC_BACKEND="python"
# export TRANSONIC_BACKEND="cythonplus"
export TRANSONIC_NO_MPI=true

[[ -d __cythonplus__ ]] && rm -fr __cythonplus__

transonic code_with_functions.py -b cythonplus --no-compile
transonic code_with_classes.py -b cythonplus --no-compile
