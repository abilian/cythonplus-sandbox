#!/bin/bash

NAME="gu_wn_python"
echo "start benchmarks for: ${NAME}"

[[ -f constants.sh ]] || exit 1
. constants.sh
ORIG="${PWD}"

export APPLICATION_ROOT="${ROOT}"
export SERVER_NAME="127.0.0.1 localhost"
export ROOT_PATH="${ROOT}"
export STATIC_FOLDER="${STATIC_FOLDER}"

####################################################################################
PID="/tmp/${NAME}.pid"
[[ -f ${PID} ]] && { kill $(cat ${PID}); sleep 2; }
LOG="/tmp/${NAME}.log"
[[ -f ${LOG} ]] && rm -f ${LOG}

echo -e "Benchmark of a typical gunicorn/flask/whitenoise configuration\n" > ${LOG}

PORT=5004
cd "bin/${NAME}"
gunicorn "${NAME}:create_app()" --preload --disable-redirect-access-to-syslog \
--log-file ${LOG} --capture-output -D -b 127.0.0.1:${PORT} -p ${PID}

sleep 1
tail -f ${LOG} &
tail_pid=$!
grep -q 'initialization' <(tail -f ${LOG})

sleep 3
echo "start requests"
# ${WRK} -c10 -d20s -t1 http://localhost:${PORT}/random_image
${WRK} -c20 -d30s -t1 -s "${ORIG}"/wrk_rnd.lua http://localhost:${PORT} >> "${LOG}" 2>&1

cd "${ORIG}"
mkdir -p results
mv "${LOG}" results/bench_${NAME}.txt

kill $(cat ${PID})
kill ${tail_pid}
[[ -f ${PID} ]] && rm ${PID}

####################################################################################
# gunicorn workers:
WORKERS=2
PID="/tmp/${NAME}.pid"
[[ -f ${PID} ]] && { kill $(cat ${PID}); sleep 2; }
LOG="/tmp/${NAME}.log"
[[ -f ${LOG} ]] && rm -f ${LOG}

echo -e "Benchmark of a gunicorn/flask/whitenoise configuration with 2 gunicorn workers\n" > ${LOG}

PORT=5004
cd "bin/${NAME}"
gunicorn "${NAME}:create_app()" --preload --workers ${WORKERS} --disable-redirect-access-to-syslog \
--log-file ${LOG} --capture-output -D -b 127.0.0.1:${PORT} -p ${PID}

sleep 1
tail -f ${LOG} &
tail_pid=$!
grep -q 'initialization' <(tail -f ${LOG})

sleep 3
echo "start requests"
# ${WRK} -c10 -d20s -t1 http://localhost:${PORT}/random_image
${WRK} -c20 -d30s -t1 -s "${ORIG}"/wrk_rnd.lua http://localhost:${PORT} >> "${LOG}" 2>&1

cd "${ORIG}"
mkdir -p results
mv "${LOG}" results/bench_${NAME}_workers_${WORKERS}.txt

kill $(cat ${PID})
kill ${tail_pid}
[[ -f ${PID} ]] && rm ${PID}
