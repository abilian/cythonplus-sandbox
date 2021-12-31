#!/bin/bash
echo "Install all"

# script to be run from this folder:
[[ -f all_install.sh ]] || exit 1

./install_packages.sh
./fetch_many_images.sh
./copy_750_images.sh
./gen_small_files.sh
