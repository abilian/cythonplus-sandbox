#!/bin/bash

if [[ ! -f app.py ]]
then
    echo "./make.sh must be launched from local demo folder. Exiting."
    exit 1
fi

# for MacOS environment, need to select some gcc compiler:
[[ "$OSTYPE" == "darwin"* ]] && source ../../../utils/gcc_macports_alias.sh

./copy_files.sh

python setup.py build_ext --inplace
