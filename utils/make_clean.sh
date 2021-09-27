#!/bin/bash

# security test
[ -z ${CYP_SANDBOX_PATH} ] && exit 1
[[ ${CYP_SANDBOX_PATH} = *cythonplus-sandbox ]] || exit 1
[ -d "${CYP_SANDBOX_PATH}" ] || exit 1

echo "clean of ${CYP_SANDBOX_PATH}"

find "${CYP_SANDBOX_PATH}" -type f -name "*.orig" -delete 
find "${CYP_SANDBOX_PATH}" -type f -name "*.cpp" -delete 
find "${CYP_SANDBOX_PATH}" -type f -name "*.so" -delete 
find "${CYP_SANDBOX_PATH}" -path "*/__pycache__/*" -delete 
find "${CYP_SANDBOX_PATH}" -type d -name "__pycache__" -delete 
find "${CYP_SANDBOX_PATH}" -path "*/build/*" -delete 
find "${CYP_SANDBOX_PATH}" -type d -name "build" -delete 

 
