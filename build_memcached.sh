#!/bin/bash

set -x

pwd

curl -sSL -H 'Cache-Control: no-cache' -o /tmp/sc01.sh https://github.com/tshr20180821/render-09/raw/main/sc01.sh
cat /tmp/sc01.sh
chmod +x /tmp/sc01.sh

curl -sSL -H 'Cache-Control: no-cache' -O https://github.com/tshr20180821/render-09/raw/main/receive.sh
cat ./receive.sh
chmod +x ./receive.sh

curl -sSL -H 'Cache-Control: no-cache' -O https://github.com/tshr20180821/render-09/raw/main/send.sh
cat ./send.sh
chmod +x ./send.sh

curl -sSL https://github.com/nwtgck/piping-server-pkg/releases/download/v1.12.9-1/piping-server-pkg-linuxstatic-x64.tar.gz | tar xzf -
./piping-server-pkg-linuxstatic-x64/piping-server --host=127.0.0.1 --http-port=8080 &

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

/usr/bin/distccd --port=13632 --listen=127.0.0.1 --user=nobody --jobs=4 --log-level=debug --log-file=${DISTCCD_LOG_FILE} --daemon --stats --stats-port=3633 --allow-private --job-lifetime=180 --nice=10

echo '***** socat *****'

# socat -ddd tcp-listen:3632,reuseaddr,fork 'exec:/tmp/sc01.sh' &
# socat -ddd tcp-listen:3632,reuseaddr,fork "exec:curl -u ${BASIC_USER}\:${BASIC_PASSWORD} --stderr /var/www/html/auth/strerr.txt -NT - https\://${RENDER_EXTERNAL_HOSTNAME}/auth/distccd.php" &
socat -ddd tcp-listen:3632,reuseaddr,fork,sndbuf=81920 "exec:curl -v --trace-time -u ${BASIC_USER}\:${BASIC_PASSWORD} --trace /var/www/html/auth/trace.txt --stderr /var/www/html/auth/strerr.txt --data-binary @- https\://${RENDER_EXTERNAL_HOSTNAME}/auth/distccd.php" &

echo '***** socat *****'

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

time MAKEFLAGS="CC=distcc\ gcc" make -j2

popd
popd
