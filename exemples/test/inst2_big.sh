#!/bin/bash
echo "Install test images"

BASE=~/tmp/wntest
[[ -d $BASE ]] || mkdir -p ${BASE}

ROOT=${BASE}/site1
[[ -d $ROOT ]] || mkdir -p ${ROOT}

cd $BASE

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

for d in ${folders}; do
    cd $BASE
    f=$d.tar
    echo $f
    [[ -f $f ]] || {
        echo "----------------------------------------------"
        curl -L -o $f http://imagedatabase.cs.washington.edu/groundtruth/_tars.for.download/$f
    }
done


cd $BASE
b="_biblio.tgz"
echo $b
[[ -f $b ]] || {
    echo "----------------------------------------------"
    curl -L -o $b https://enneagon.org/$b
}


STATIC=${ROOT}/static
[[ -d $STATIC ]] || mkdir -p ${STATIC}

cd  ${STATIC}
for d in ${folders}; do
    [[ -d $d ]] && rm -fr $d
    f=${BASE}/$d.tar
    tar xvf $f -C ${STATIC}
done

[[ -d biblio ]] && rm -fr biblio
f=${BASE}/_biblio.tgz
tar xvzf $f -C ${STATIC}
