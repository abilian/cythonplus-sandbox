#!/bin/bash -v

name="string_exp"

[ -f ${name}.cpp ] && rm ${name}.cpp

python setup.py build_ext --inplace

python -c "import ${name}; ${name}.main()"
