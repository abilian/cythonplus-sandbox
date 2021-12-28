#!/bin/bash

NAME="actor_static_server"
echo "start benchmarks for: ${NAME}"

[[ -f constants.sh ]] || exit 1
. constants.sh
ORIG="${PWD}"

####################################################################################
# benchmark 1: nb of workers = auto
PID="/tmp/actor_server.pid"
[[ -f ${PID} ]] && { kill $(cat ${PID}); sleep 2; }
LOG="/tmp/ass.log"
[[ -f ${LOG} ]] && rm -f ${LOG}

PORT=5016
# WORKERS=0 => auto detect
WORKERS=0
cd bin
command="import ${NAME} as s; s.start_server(pidfile='${PID}', addr='127.0.0.1', \
port='${PORT}', site_root='${ROOT}', static_folder='${STATIC_FOLDER}', \
prefix=None, log_file='${LOG}', workers='${WORKERS}')"
python -c "${command}"
sleep 1
tail -f ${LOG} &
tail_pid=$!
grep -q 'initialization' <(tail -f ${LOG})

sleep 1
echo "start requests"
${WRK} -c20 -d30s -t1 -s "${ORIG}"/wrk_rnd.lua http://localhost:${PORT} >> "${LOG}" 2>&1

cd "${ORIG}"
mkdir -p results
mv "${LOG}" results/bench_actor_static_server_workers_auto.txt

kill $(cat ${PID})
[[ -f ${PID} ]] && rm ${PID}
kill ${tail_pid}

####################################################################################
# benchmark 2: nb of workers = 2
PID="/tmp/actor_server.pid"
[[ -f ${PID} ]] && { kill $(cat ${PID}); sleep 2; }
LOG="/tmp/ass.log"
[[ -f ${LOG} ]] && rm -f ${LOG}

PORT=5016
# WORKERS=2  # for best perfs, use actual nb of cores without hyperthreading
WORKERS=2
cd bin
command="import ${NAME} as s; s.start_server(pidfile='${PID}', addr='127.0.0.1', \
port='${PORT}', site_root='${ROOT}', static_folder='${STATIC_FOLDER}', \
prefix=None, log_file='${LOG}', workers='${WORKERS}')"
python -c "${command}"
sleep 1
tail -f ${LOG} &
tail_pid=$!
grep -q 'initialization' <(tail -f ${LOG})

sleep 1
echo "start requests"
${WRK} -c20 -d30s -t1 -s "${ORIG}"/wrk_rnd.lua http://localhost:${PORT} >> "${LOG}" 2>&1

cd "${ORIG}"
mkdir -p results
mv "${LOG}" results/bench_actor_static_server_workers_2.txt

kill $(cat ${PID})
[[ -f ${PID} ]] && rm ${PID}
kill ${tail_pid}
echo "---------------"
