#!/bin/bash

set -x

KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)

echo 'start curl 1'

curl -X POST -d 'post_piping_server' https://piping-47q675ro2guv.runkit.sh//${KEYWORD}

echo 'finish curl 1'

echo 'start curl 2'

curl https://piping-47q675ro2guv.runkit.sh/${KEYWORD}

echo 'finish curl 2'
