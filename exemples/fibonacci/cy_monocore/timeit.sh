#!/bin/bash

python -m timeit "from fibonacci_cy_monocore import main; main(1476)"
