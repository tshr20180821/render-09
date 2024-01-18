#!/bin/bash

set -x

echo "test.sh $$ start" >&2

data=$(cat -) | base64 -w 0

echo "test.sh $$ readed" >&2

KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)

curl -sSm60 -u ${BASIC_USER}:${BASIC_PASSWORD} \
  -d "keywork=${KEYWORD}" \
  -d "server=${RENDER_EXTERNAL_HOSTNAME}/piping" \
  https://${RENDER_EXTERNAL_HOSTNAME}/auth/socat.php &

# curl -sSo ./${KEYWORD} https://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}res &
curl -sSm 60 -o ./${KEYWORD} https://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}res &

# echo ${data} | curl -sST - https://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}req
echo -n ${data} | gzip -c | curl -H 'Content-Encoding: gzip' -sST - https://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}req

while true; do \
  if [ -f ./${KEYWORD} ]; then
    sleep 3s
    echo -n "test.sh $$ result : " && cat ./${KEYWORD} >&2
    cat ./${KEYWORD} | base64 -d
    rm ./${KEYWORD}
    exit 0
  fi
  sleep 1s
done
