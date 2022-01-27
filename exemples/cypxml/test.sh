#!/bin/bash
NAME="cypxml"

cd build
python -c "from ${NAME} import test_xml_utils as t ; t.main()"
python -c "from ${NAME} import test_cypxml as t ; t.main()"
cd ..
