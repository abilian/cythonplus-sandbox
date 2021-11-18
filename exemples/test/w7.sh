#!/bin/bash -v

WRK=~/tmp/wntest/wrk/wrk

${WRK} -c10 -d3s -t1 http://localhost:5000/random_image
