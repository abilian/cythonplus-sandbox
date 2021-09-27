#!/bin/bash

if [[ ! -f test_containerlib.sh ]]
then
    echo "test.sh must be launched from local folder. Exiting."
    exit 1
fi

./test_containerlib.sh
