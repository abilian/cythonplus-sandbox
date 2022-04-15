#!/bin/bash
NAME="gu_wn_python"
msg="Basic gunicorn/flask/whitenoise configuration, 20 gunicorn workers, small files"
WORKERS=20

[[ -f constants.sh ]] || exit 1
. constants.sh
ORIG="${PWD}"

export APPLICATION_ROOT="${ROOT}"
export SERVER_NAME="127.0.0.1 localhost"
export ROOT_PATH="${ROOT}"
export STATIC_FOLDER="${STATIC_FOLDER}"

PID="/tmp/${NAME}.pid"
[[ -f ${PID} ]] && { kill $(cat ${PID}); sleep 2; }
LOG="/tmp/${NAME}.log"
[[ -f ${LOG} ]] && rm -f ${LOG}
tail -f ${LOG} &
tail_pid=$!

echo -e "${msg}\n" > ${LOG}

PORT=5004
cd "bin/${NAME}"
gunicorn "${NAME}:create_app()" --preload --workers ${WORKERS} --disable-redirect-access-to-syslog \
--log-file ${LOG} --capture-output -D -b 127.0.0.1:${PORT} -p ${PID}
sleep 1

grep -q 'initialization' <(tail -f ${LOG})

sleep 3
echo "start requests"
# ${WRK} -c10 -d20s -t1 http://localhost:${PORT}/random_image
${WRK} -c80 -d30s -t4 -s "${ORIG}"/wrk_rnd_small.lua http://localhost:${PORT} >> "${LOG}" 2>&1

cd "${ORIG}"
mkdir -p results
script_sh=$(basename "$0")
RESULT_FILE="${script_sh%.sh}.txt"
mv "${LOG}" results/"${RESULT_FILE}"

kill ${tail_pid}

kill $(cat ${PID})
[[ -f ${PID} ]] && rm ${PID}
