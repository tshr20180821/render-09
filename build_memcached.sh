#!/bin/bash

set -x

DEBIAN_FRONTEND=noninteractive apt-get -q install -y --no-install-recommends \
  build-essential \
  distcc \
  gcc-x86-64-linux-gnu \
  socat \
  >/dev/null

DISTCCD_LOG_FILE=/var/www/html/auth/distccd_log.txt
touch ${DISTCCD_LOG_FILE}
chmod 666 ${DISTCCD_LOG_FILE}

/usr/bin/distccd --port=13632 --listen=127.0.0.1 --user=nobody --jobs=4 --log-level=debug --log-file=${DISTCCD_LOG_FILE} --daemon --stats --stats-port=3633 --allow-private --job-lifetime=180 --nice=10

socat -4 tcp-listen:3632,bind=127.0.0.1,reuseaddr,fork "exec:curl -u ${BASIC_USER}:${BASIC_PASSWORD} -sSNT - https://${RENDER_EXTERNAL_HOSTNAME}/auth/distccd.php"


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
