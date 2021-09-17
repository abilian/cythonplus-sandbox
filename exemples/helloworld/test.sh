#!/bin/bash -v

# for MacOS environment, need to select some gcc compiler:
[[ "$OSTYPE" == "darwin"* ]] && source gcc_macports_alias.sh

[ -f helloworld.cpp ] && rm helloworld.cpp

python setup.py build_ext --inplace

python -c "import helloworld; helloworld.main()"
