#!/bin/bash
echo "start app: t6_cyp_min"

PID="gun6.pid"
[[ -f ${PID} ]] && { kill $(cat ${PID}); sleep 2; }
LOG="g.log"
[[ -f ${LOG} ]] && rm -f ${LOG}

PORT=5006
gunicorn "t6_cyp_min:create_app()" --preload --disable-redirect-access-to-syslog --log-file ${LOG} --capture-output -D -b 127.0.0.1:${PORT} -p ${PID}
sleep 1
tail -f ${LOG} &
grep -q 'initialization' <(tail -f ${LOG})

sleep 3
echo "start requests"
WRK=~/tmp/wntest/wrk/wrk
${WRK} -c10 -d20s -t1 http://localhost:${PORT}/random_image

kill $(cat ${PID})
exit
