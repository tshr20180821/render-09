#!/bin/bash

set -x

KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)

DEBIAN_FRONTEND=noninteractive apt-get -qq install -y --no-install-recommends \
  build-essential \
  distcc \
  gcc-x86-64-linux-gnu \
  socat \
  >/dev/null

DISTCCD_LOG_FILE=/var/www/html/auth/distccd_log.txt
touch ${DISTCCD_LOG_FILE}
chmod 666 ${DISTCCD_LOG_FILE}

export DISTCC_TCP_CORK=0
# /usr/bin/distccd --port=13632 --listen=127.0.0.1 --user=nobody --jobs=2 --log-level=debug --log-file=${DISTCCD_LOG_FILE} --daemon --stats --stats-port=3633 --allow-private
/usr/bin/distccd --port=13632 --listen=127.0.0.1 --jobs=2 --log-level=debug --log-file=${DISTCCD_LOG_FILE} --daemon --stats --stats-port=3633 --allow-private

sleep 3s

# curl ${PIPING_SERVER}/help

curl -sSL https://github.com/nwtgck/piping-server-pkg/releases/download/v1.12.9-1/piping-server-pkg-linuxstatic-x64.tar.gz | tar xzf -
./piping-server-pkg-linuxstatic-x64/piping-server --host=127.0.0.1 --http-port=8080 &

# curl -sSL https://github.com/nwtgck/piping-server-rust/releases/download/v0.16.0/piping-server-x86_64-unknown-linux-musl.tar.gz | tar xzf -
# ./piping-server-x86_64-unknown-linux-musl/piping-server --host=127.0.0.1 --http-port=8081 &

sleep 3s

socat "exec:curl -NsS https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}xxx!!exec:curl -NsS --data-binary @- https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}yyy" tcp:127.0.0.1:13632 &

socat tcp-listen:3632,bind=127.0.0.1,reuseaddr,nonblock=1 "exec:curl -NsS https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}yyy!!exec:curl -NsS --data-binary @- https\://${RENDER_EXTERNAL_HOSTNAME}/piping/${KEYWORD}xxx" &

sleep 3s
ss -anpt

apt-get install -y libevent-dev >/dev/null 2>&1

gcc -### -E - -march=native 2>&1 | sed -r '/cc1/!d;s/(")|(^.* - )//g' >/tmp/cflags_option
cflags_option=$(cat /tmp/cflags_option)
export CFLAGS="-O2 ${cflags_option} -pipe -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

pushd /tmp
curl -sSO https://memcached.org/files/memcached-1.6.22.tar.gz
tar xf memcached-1.6.22.tar.gz

# export DISTCC_VERBOSE=1
# export DISTCC_HOSTS="127.0.0.1/1,cpp,lzo localhost/1"
export DISTCC_HOSTS="127.0.0.1"
export DISTCC_POTENTIAL_HOSTS="${DISTCC_HOSTS}"
export DISTCC_FALLBACK=0
export DISTCC_TCP_CORK=0

pushd memcached-1.6.22

./configure --disable-docs >/dev/null

time MAKEFLAGS="CC=distcc\ gcc" make -j4

popd
popd
