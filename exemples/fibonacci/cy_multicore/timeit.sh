#!/bin/bash

python -m timeit "from fibonacci_cy_multicore import main; main(1476)"
