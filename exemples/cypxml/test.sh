#!/bin/bash
NAME="cypxml"

cd build
python -c "from ${NAME} import test_xml_utils as t ; t.main()"
cd ..
