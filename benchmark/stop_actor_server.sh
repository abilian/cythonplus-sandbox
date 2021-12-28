#!/bin/bash

NAME="actor_static_server"
echo "stop server: ${NAME}"

PID="/tmp/${NAME}.pid"
[[ -f ${PID} ]] && { kill $(cat ${PID}); sleep 2; }
[[ -f ${PID} ]] && rm ${PID}
