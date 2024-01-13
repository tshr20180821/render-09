#!/bin/bash

set -x

apt-get install -y distcc socat recode >/dev/null 2>&1

# start piping-duplex

curl -sSLO https://github.com/nwtgck/go-piping-duplex/releases/download/v0.3.0-release-trigger2/piping-duplex-0.3.0-release-trigger2-linux-amd64.tar.gz
tar xf piping-duplex-0.3.0-release-trigger2-linux-amd64.tar.gz
chmod +x piping-duplex

# export PIPING_SERVER=https://piping.glitch.me
# export PIPING_SERVER=https://piping-47q675ro2guv.runkit.sh/

# finish piping-duplex

# start socat

KEYWORD=$(curl -sS -u ${BASIC_USER}:${BASIC_PASSWORD} ${SERVER01}/auth/keyword.txt)
export PIPING_SERVER=$(curl -sS -u ${BASIC_USER}:${BASIC_PASSWORD} ${SERVER01}/auth/piping_server.txt)

# client
# socat -4 tcp-listen:3632,bind=127.0.0.1,reuseaddr,fork "exec:./piping-duplex ${KEYWORD}distccd_response ${KEYWORD}distccd_request" &
socat -v -d -4 tcp-listen:9001,bind=127.0.0.1,reuseaddr,fork "exec:./piping-duplex ${KEYWORD}distccd_response ${KEYWORD}distccd_request" &
socat -4 tcp-listen:3632,bind=127.0.0.1,reuseaddr,fork 'system:"stdbuf -o0 recode ../b64 | socat - tcp:127.0.0.1:9001,end-close"' &

# finish socat

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

time MAKEFLAGS="CC=distcc\ gcc" make -j2 2>&1 | tee -a /var/www/html/auth/build_log.txt

popd
popd
