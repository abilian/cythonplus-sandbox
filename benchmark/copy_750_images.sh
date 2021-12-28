#!/bin/bash
echo "Copy 750 jpg to the static/images folder"

# script to be run from this folder:
[[ -f copy_750_images.sh ]] || exit 1

. constants.sh
python copy_750_images.py "${IMGSRC}" "${IMAGES}"
