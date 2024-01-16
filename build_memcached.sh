#!/bin/bash

set -x

curl ${PIPING_SERVER}/help

KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)

curl -sSL https://github.com/nwtgck/piping-server-pkg/releases/download/v1.12.9-1/piping-server-pkg-linuxstatic-x64.tar.gz | tar xzf -
./piping-server-pkg-linuxstatic-x64/piping-server --host=127.0.0.1 --http-port=8080 &

curl -sSL https://github.com/nwtgck/piping-server-rust/releases/download/v0.16.0/piping-server-x86_64-unknown-linux-musl.tar.gz | tar xzf -
./piping-server-x86_64-unknown-linux-musl/piping-server --host=127.0.0.1 --http-port=8081 &

echo 'start curl 1'

echo 'post_piping_server' | curl -X POST --data-binary @- https://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD} &

echo 'finish curl 1'

echo 'start curl 2'

echo 'post_piping_server_rust' | curl -X POST --data-binary @- https://${RENDER_EXTERNAL_HOSTNAME}/piping_rust/${KEYWORD}rust &

echo 'finish curl 2'

echo 'start curl 3'

curl https://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}

echo 'finish curl 3'

echo 'start curl 4'

curl https://${RENDER_EXTERNAL_HOSTNAME}/piping_rust/${KEYWORD}rust

echo 'finish curl 4'
