#!/bin/bash

NAME="t16_server"
echo "start app: ${NAME}"

PID="/tmp/server_cyp.pid"
[[ -f ${PID} ]] && { kill $(cat ${PID}); sleep 2; }
LOG="/tmp/a.log"
[[ -f ${LOG} ]] && rm -f ${LOG}

PORT=5016
# gunicorn "${NAME}:create_app()" --preload --disable-redirect-access-to-syslog --log-file ${LOG} --capture-output -D -b 127.0.0.1:${PORT} -p ${PID}
# gunicorn "${NAME}:create_app()" --preload --disable-redirect-access-to-syslog --log-file ${LOG} --capture-output --threads 2 -D -b 127.0.0.1:${PORT} -p ${PID}
python server_cyp_start.py
sleep 1
tail -f ${LOG} &
tail_pid=$!
grep -q 'initialization' <(tail -f ${LOG})

sleep 3
echo "start requests"
WRK=~/tmp/wntest/wrk/wrk
# ${WRK} -c10 -d20s -t1 http://localhost:${PORT}/random_image
${WRK} -c5 -d1s -t1 -s ./rnd.lua http://localhost:${PORT}

kill $(cat ${PID})
[ -f ${PID} ] && rm ${PID}
kill ${tail_pid}
exit
