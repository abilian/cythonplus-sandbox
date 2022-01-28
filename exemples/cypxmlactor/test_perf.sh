#!/bin/bash
NAME="cypxmlactor"

echo "======== bench ========"
python py_xmlwitch_large.py
cd build
python -c "from ${NAME} import test_perf as t ; t.main()"
cd ..
