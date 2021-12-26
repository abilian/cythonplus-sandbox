#!/bin/bash

NAME="t15_cyp_h"
echo "start app: ${NAME}"

PID="gun15.pid"
[[ -f ${PID} ]] && { kill $(cat ${PID}); sleep 2; }
LOG="g.log"
[[ -f ${LOG} ]] && rm -f ${LOG}

PORT=5015
gunicorn "${NAME}:create_app()" --preload --disable-redirect-access-to-syslog --log-file ${LOG} --capture-output -D -b 127.0.0.1:${PORT} -p ${PID}
#gunicorn "${NAME}:create_app()" --preload --disable-redirect-access-to-syslog --log-file ${LOG} --capture-output --threads 2 -D -b 127.0.0.1:${PORT} -p ${PID}
sleep 1
tail -f ${LOG} &
tail_pid=$!
grep -q 'initialization' <(tail -f ${LOG})

sleep 3
echo "start requests"
WRK=~/tmp/wntest/wrk/wrk
# ${WRK} -c10 -d20s -t1 http://localhost:${PORT}/random_image
${WRK} -c10 -d30s -t1 -s ./rnd.lua http://localhost:${PORT}

kill $(cat ${PID})
kill ${tail_pid}
exit
