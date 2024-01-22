#!/bin/bash

set -x

curl -sSL -H 'Cache-Control: no-cache' -o /var/www/html/auth/distccd.php https://github.com/tshr20180821/render-09/raw/main/auth/distccd.php
cat /var/www/html/auth/distccd.php

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

# socat -ddd -b 81920 tcp-listen:3632,bind=127.0.0.1,reuseaddr,fork,sndbuf=81920 \
#   "exec:php /var/www/html/auth/distccd.php" &

socat -d -b 81920 tcp-listen:3632,bind=127.0.0.1,reuseaddr,fork,sndbuf=81920 \
  "exec:php /var/www/html/auth/send.php" &

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

# export DISTCC_HOSTS="127.0.0.1/1,cpp,lzo localhost/1"
export DISTCC_HOSTS="127.0.0.1,lzo"
export DISTCC_POTENTIAL_HOSTS="${DISTCC_HOSTS}"
export DISTCC_FALLBACK=0
# export DISTCC_TCP_CORK=0
# export DISTCC_VERBOSE=1

pushd memcached-1.6.22

./configure --disable-docs >/dev/null

time MAKEFLAGS="CC=distcc\ gcc" make -j2

popd
popd

ls -lang /var/www/html/auth/
