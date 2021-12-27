#!/bin/bash

NAME="actor server"
echo "start app: ${NAME}"

PID="/tmp/actor_server.pid"
[[ -f ${PID} ]] && { kill $(cat ${PID}); sleep 2; }
LOG="/tmp/afs.log"
[[ -f ${LOG} ]] && rm -f ${LOG}

PORT=5016
WORKERS=2  # for best perfs, use actual nb of cores without hyperthreading
python -c "import server as s; s.start_server(pidfile='${PID}', port='${PORT}', log_file='${LOG}', workers='${WORKERS}')"
sleep 1
tail -f ${LOG} &
tail_pid=$!
grep -q 'initialization' <(tail -f ${LOG})

sleep 1
echo "start requests"
WRK=~/tmp/wntest/wrk/wrk
# ${WRK} -c10 -d20s -t1 http://localhost:${PORT}/random_image
${WRK} -c20 -d30s -t1 -s ./rnd.lua http://localhost:${PORT}

kill $(cat ${PID})
[ -f ${PID} ] && rm ${PID}
kill ${tail_pid}
exit
