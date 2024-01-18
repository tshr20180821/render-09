#!/bin/bash

set -x

echo "receive.sh $$ start" >&2

curl -sS -u "${BASIC_USER}:${BASIC_PASSWORD} https://${server}/${keyword}req | base64 -d
