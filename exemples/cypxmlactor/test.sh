#!/bin/bash
NAME="cypxmlactor"

cd build
python -c "from ${NAME} import test_xml_utils as t ; t.main()"
python -c "from ${NAME} import test_cypxmlactor as t ; t.main()"
cd ..
