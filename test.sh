#!/bin/bash

set -x

# socat -d tcp-listen:3632,reuseaddr,fork 'exec:base64 -w0 | ./test.sh' &

read -r line

KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)

curl -sSm60 -u ${BASIC_USER}:${BASIC_PASSWORD} \
  -d "keywork=${KEYWORD}" \
  -d "server=${RENDER_EXTERNAL_HOSTNAME}/piping" \
  https://${RENDER_EXTERNAL_HOSTNAME}/auth/socat.php &

# curl -sSo ./${KEYWORD} https://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}res &
curl -sSm 60 -o ./${KEYWORD} https://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}res &

# echo ${line} | curl -sST - https://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}req
echo ${line} | gzip -c | curl -H 'Content-Encoding: gzip' -sST - https://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}req

while true; do \
  if [ -f ./${KEYWORD} ]; then
    sleep 3s
    echo -n "$$ result : " && cat ./${KEYWORD} >&2
    cat ./${KEYWORD} | base64 -d
    rm ./${KEYWORD}
    exit 0
  fi
  sleep 1s
done
