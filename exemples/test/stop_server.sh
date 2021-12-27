#!/bin/bash

NAME="actor server"
echo "stop app: ${NAME}"

PID="/tmp/actor_server.pid"

kill $(cat ${PID})
[ -f ${PID} ] && rm ${PID}
