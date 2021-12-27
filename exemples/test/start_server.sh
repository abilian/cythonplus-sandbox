#!/bin/bash

NAME="actor server"
echo "start app: ${NAME}"

PID="/tmp/actor_server.pid"
[[ -f ${PID} ]] && { kill $(cat ${PID}); sleep 2; }
LOG="/tmp/afs.log"
[[ -f ${LOG} ]] && rm -f ${LOG}

PORT=5016
python -c "import server as s; s.start_server(pidfile='${PID}', addr='0.0.0.0', port='${PORT}', log_file='${LOG}')"
sleep 1
tail -f ${LOG} &
tail_pid=$!
grep -q 'initialization' <(tail -f ${LOG})
