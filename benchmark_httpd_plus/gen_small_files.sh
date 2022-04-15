#!/bin/bash
echo "Generate 50000 small files"

# script to be run from this folder:
[[ -f gen_small_files.sh ]] || exit 1

. constants.sh
python gen_small_files.py "${SMALL}"
