#!/bin/bash

NAME="server"
echo "start app: ${NAME}"

PID="/tmp/server_cyp.pid"
[[ -f ${PID} ]] && { kill $(cat ${PID}); sleep 2; }
LOG="/tmp/a.log"
[[ -f ${LOG} ]] && rm -f ${LOG}

PORT=5016
python -c "import server as s; s.start_server()"
sleep 1
tail -f ${LOG} &
tail_pid=$!
grep -q 'initialization' <(tail -f ${LOG})

sleep 3
echo "start requests"
WRK=~/tmp/wntest/wrk/wrk
# ${WRK} -c10 -d20s -t1 http://localhost:${PORT}/random_image
${WRK} -c10 -d10s -t1 -s ./rnd.lua http://localhost:${PORT}

kill $(cat ${PID})
[ -f ${PID} ] && rm ${PID}
kill ${tail_pid}
exit
               
