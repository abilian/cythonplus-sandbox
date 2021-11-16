#!/bin/bash
echo "Install test images"

BASE=~/tmp/wntest
[[ -d $BASE ]] || mkdir -p ${BASE}

ROOT=${BASE}/site1
[[ -d $ROOT ]] || mkdir -p ${ROOT}

GT=${BASE}/groundtruth
[[ -d $GT ]] || mkdir -p ${GT}

cd $BASE

folders="
australia
barcelona
arborgreens
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

STATIC=${ROOT}/static
[[ -d $STATIC ]] || mkdir -p ${STATIC}

cd  ${STATIC}
for d in ${folders}; do
    [[ -d $d ]] && rm -fr $d
    f=${BASE}/$d.tar
    tar xvf $f -C ${STATIC}
done
