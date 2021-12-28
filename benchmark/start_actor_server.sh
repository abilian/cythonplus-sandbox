#!/bin/bash

NAME="actor_static_server"
echo "start server: ${NAME}"

PID="/tmp/${NAME}.pid"
[[ -f ${PID} ]] && { kill $(cat ${PID}); sleep 2; }
LOG="/tmp/${NAME}.log"
[[ -f ${LOG} ]] && rm -f ${LOG}

cd bin
command="import ${NAME} as s; s.start_server(pidfile='${PID}', addr='127.0.0.1', \
port='${PORT}', site_root='${ROOT}', static_folder='${STATIC_FOLDER}', \
prefix=None, log_file='${LOG}', workers='${WORKERS}')"
python -c "${command}"
sleep 1
tail -f ${LOG} &
tail_pid=$!
grep -q 'initialization' <(tail -f ${LOG})
