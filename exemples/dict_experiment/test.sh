#!/bin/bash

names="
dict_exp_num
"

# for MacOS environment, need to select some gcc compiler:
[[ "$OSTYPE" == "darwin"* ]] && source ../../utils/gcc_macports_alias.sh

for name in ${names}
do
    [ -f ${name}.cpp ] && rm ${name}.cpp
done

for name in ${names}
do
    echo "----------  ${name}  ---------------"
    python setup_${name}.py build_ext --inplace
done
echo "--------------------------------------"

for name in ${names}
do
    echo ${name}
    python -c "import ${name}; ${name}.main()"
    echo "--------------------------------------"
done
