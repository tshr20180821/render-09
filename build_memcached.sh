#!/bin/bash

set -x

curl ${PIPING_SERVER}/help

KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 16 | head -n 1)

echo 'start curl 1'

echo 'piping_server' | curl --http1.1 -vT - ${PIPING_SERVER}/${KEYWORD}

echo 'finish curl 1'

echo 'start curl 2'

curl ${PIPING_SERVER}/${KEYWORD}

echo 'finish curl 2'
