#!/bin/bash
echo "Fetch test images"

# script to be run from this folder:
[[ -f fetch_many_images.sh ]] || exit 1

. constants.sh
ORIG="$PWD"

[[ -d $IMGSRC ]] || mkdir -p ${IMGSRC}


folders="
australia
barcelona
arborgreens
cambridge
campusinfall
cannonbeach
cherries
columbiagorge
football
geneva
greenlake
greenland
indonesia
iran
italy
japan
leaflesstrees
sanjuans
springflowers
swissmountains
yellowstone
"

cd ${IMGSRC}

for d in ${folders}; do
    f=$d.tar
    echo $f
    [[ -f $f ]] || {
        echo "----------------------------------------------"
        curl -L -o $f http://imagedatabase.cs.washington.edu/groundtruth/_tars.for.download/$f
    }
done


for d in ${folders}; do
    cd ${IMGSRC}
    [[ -d $d ]] && rm -fr $d
    tarfile=${IMGSRC}/$d.tar
    tar xvf ${tarfile} -C ${IMGSRC}
done
