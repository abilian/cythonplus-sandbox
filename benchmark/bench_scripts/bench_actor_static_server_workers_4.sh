#!/bin/bash

NAME="actor_static_server"
echo "start benchmarks for: ${NAME}"

[[ -f constants.sh ]] || exit 1
. constants.sh
ORIG="${PWD}"

####################################################################################
# benchmark: nb of workers = 4
####################################################################################
WORKERS=4
RESULT_FILE="bench_actor_server_workers_${WORKERS}.txt"
PID="/tmp/${NAME}.pid"
[[ -f ${PID} ]] && { kill $(cat ${PID}); sleep 2; }
LOG="/tmp/${NAME}.log"
[[ -f ${LOG} ]] && rm -f ${LOG}

echo -e "Benchmark of the actor server with ${WORKERS} workers\n" > ${LOG}

PORT=5016
# WORKERS=2  # for best perfs, use actual nb of cores without hyperthreading
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
mv "${LOG}" results/${RESULT_FILE}

kill $(cat ${PID})
[[ -f ${PID} ]] && rm ${PID}
kill ${tail_pid}
