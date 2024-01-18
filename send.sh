#!/bin/bash

set -x

echo "send.sh $$ start" >&2

cat - | base64 -w0 | curl -u "${BASIC_USER}:${BASIC_PASSWORD} -sST - https://${server}/${keyword}res
