#!/bin/bash

set -x

echo "$0 $$ start" >&2

curl -sS -u "${BASIC_USER}:${BASIC_PASSWORD} https://${server}/${keyword}req | base64 -d
