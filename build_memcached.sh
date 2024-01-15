#!/bin/bash

set -x

DEBIAN_FRONTEND=noninteractive apt-get -q install -y --no-install-recommends \
  build-essential \
  distcc \
  gcc-x86-64-linux-gnu

KEYWORD=$(curl -sS -u ${BASIC_USER}:${BASIC_PASSWORD} ${SERVER01}/auth/keyword.txt)
PIPING_SERVER=$(curl -sS -u ${BASIC_USER}:${BASIC_PASSWORD} ${SERVER01}/auth/piping_server.txt)

curl -sSLO https://github.com/nwtgck/go-piping-tunnel/releases/download/v0.10.1/piping-tunnel-0.10.1-linux-amd64.deb
dpkg -i ./piping-tunnel-0.10.1-linux-amd64.deb

whereis piping-tunnel
piping-tunnel client -k --http-read-buf-size 80960 --http-write-buf-size 80960 -s ${PIPING_SERVER} --port 3632 --yamux ${KEYWORD}req ${KEYWORD}res &

sleep 3s
ss -anpt
ps aux

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
export DISTCC_HOSTS="127.0.0.1:3632"
export DISTCC_POTENTIAL_HOSTS="${DISTCC_HOSTS}"

pushd memcached-1.6.22

./configure --disable-docs >/dev/null

time MAKEFLAGS="CC=distcc\ gcc" make -j1 2>&1 | tee -a /var/www/html/auth/build_log.txt

popd
popd
