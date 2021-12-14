#!/bin/bash

NAME="t14_cyp_g_fw"
echo "start app: ${NAME}"
#
# PID="gun11.pid"
# [[ -f ${PID} ]] && { kill $(cat ${PID}); sleep 2; }
# LOG="g.log"
# [[ -f ${LOG} ]] && rm -f ${LOG}

PORT=5000
# ./t14_cyp_g_fw.py &
# gunicorn "${NAME}:create_app()" --preload --disable-redirect-access-to-syslog --log-file ${LOG} --capture-output --threads 2 -D -b 127.0.0.1:${PORT} -p ${PID}
sleep 4
#tail -f ${LOG} &
#grep -q 'initialization' <(tail -f ${LOG})

sleep 3
echo "start requests"
WRK=~/tmp/wntest/wrk/wrk
# ${WRK} -c10 -d20s -t1 http://localhost:${PORT}/random_image
${WRK} -c10 -d20s -t1 -s ./rnd.lua http://localhost:${PORT}

kill $(cat ${PID})
exit
