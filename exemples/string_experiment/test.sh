#!/bin/bash -v

name="string_exp"

# for MacOS environment, need to select some gcc compiler:
[[ "$OSTYPE" == "darwin"* ]] && source ../../utils/gcc_macports_alias.sh

[ -f ${name}.cpp ] && rm ${name}.cpp

python setup.py build_ext --inplace

python -c "import ${name}; ${name}.main()"
