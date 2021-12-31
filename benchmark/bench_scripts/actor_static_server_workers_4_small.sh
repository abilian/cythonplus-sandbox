#!/bin/bash
NAME="actor_static_server"
msg="Actor server with 4 workers, HTTP/1.1, small files"
WORKERS=4
PROTOCOL=1

[[ -f constants.sh ]] || exit 1
. constants.sh
ORIG="${PWD}"

PID="/tmp/${NAME}.pid"
[[ -f ${PID} ]] && { kill $(cat ${PID}); sleep 2; }
LOG="/tmp/${NAME}.log"
[[ -f ${LOG} ]] && rm -f ${LOG}
tail -f ${LOG} &
tail_pid=$!

echo -e "${msg}\n" > ${LOG}

PORT=5016
cd bin
command="import ${NAME} as s; s.start_server(pidfile='${PID}', addr='127.0.0.1', \
port='${PORT}', site_root='${ROOT}', static_folder='${STATIC_FOLDER}', \
prefix=None, log_file='${LOG}', workers='${WORKERS}', protocol='${PROTOCOL}')"
python -c "${command}"
sleep 1

grep -q 'initialization' <(tail -f ${LOG})

sleep 1
echo "start requests"
${WRK} -c80 -d30s -t4 -s "${ORIG}"/wrk_rnd_small.lua http://localhost:${PORT} >> "${LOG}" 2>&1

cd "${ORIG}"
mkdir -p results
script_sh=$(basename "$0")
RESULT_FILE="${script_sh%.sh}.txt"
mv "${LOG}" results/"${RESULT_FILE}"

kill ${tail_pid}
./stop_actor_server.sh
