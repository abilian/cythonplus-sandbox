#!/bin/bash

NAME="actor_static_server_h11"
echo "start app: ${NAME}"

WORKERS=0
PID="/tmp/${NAME}.pid"
[[ -f ${PID} ]] && { kill $(cat ${PID}); sleep 2; }
LOG="/tmp/${NAME}.log"
[[ -f ${LOG} ]] && rm -f ${LOG}

echo -e "Benchmark of the actor server h1.1 with auto detection of cores\n" > ${LOG}

PORT=5016
PROTO=0
WORKERS=2  # for best perfs, use actual nb of cores without hyperthreading
command="import ${NAME} as s; s.start_server(pidfile='${PID}', addr='127.0.0.1', \
port='${PORT}', site_root='${ROOT}', static_folder='${STATIC_FOLDER}', \
prefix=None, log_file='${LOG}', workers='${WORKERS}', protocol='${PROTO}')"
python -c "${command}"
sleep 1
tail -f ${LOG} &
tail_pid=$!
grep -q 'initialization' <(tail -f ${LOG})

sleep 1
echo "start requests"
WRK=~/tmp/wntest/wrk/wrk
${WRK} -c20 -d30s -t1 -s ./rnd.lua http://localhost:${PORT}
#${WRK} -c20 -d3s -t1 -s ./rnd.lua http://localhost:${PORT} >> "${LOG}" 2>&1

[ -f ${PID} ] && kill $(cat ${PID})
[ -f ${PID} ] && rm ${PID}
kill ${tail_pid}
exit
