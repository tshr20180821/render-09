#!/bin/bash

set -x

whereis distcc
whereis distccd

curl -L https://github.com/nwtgck/piping-server-pkg/releases/download/v1.12.9-1/piping-server-pkg-linuxstatic-x64.tar.gz | tar xzf -
./piping-server-pkg-linuxstatic-x64/piping-server --http-port=8080 &

# server
# POST : curl --data-binary @- https://hoge/hoge
# socat TCP-LISTEN:3633,bind=127.0.0.1,reuseaddr,fork 'EXEC:exec /usr/bin/distccd --log-level warning --log-file /var/www/html/auth/distccd_log.txt -'
# socat 'EXEC:curl -NsS https\://${RENDER_EXTERNAL_HOSTNAME}/piping/distccd_request!!EXEC:curl -NsST - https\://${RENDER_EXTERNAL_HOSTNAME}/piping/distccd_response' TCP:127.0.0.1:3633
touch /var/www/html/auth/distccd_log.txt
chmod 666 /var/www/html/auth/distccd_log.txt
socat -v "EXEC:curl -NsS https\://${RENDER_EXTERNAL_HOSTNAME}/piping/distccd_request!!EXEC:curl -NsST - https\://${RENDER_EXTERNAL_HOSTNAME}/piping/distccd_response" \
  'EXEC:/usr/bin/distccd --log-level info --log-file /var/www/html/auth/distccd_log.txt -' &

# client
socat -x TCP-LISTEN:3632,bind=127.0.0.1,reuseaddr,fork \
  "EXEC:curl -NsS https\://${RENDER_EXTERNAL_HOSTNAME}/piping/distccd_response!!EXEC:curl -NsST - https\://${RENDER_EXTERNAL_HOSTNAME}/piping/distccd_request" &

sleep 3s
ss -ant
ps aux

apt-get -qq update
apt-get install -y libevent-dev

pushd /tmp
curl -sSO https://memcached.org/files/memcached-1.6.22.tar.gz
tar xf memcached-1.6.22.tar.gz

export DISTCC_HOSTS="127.0.0.1:3632/1 localhost/1"
export DISTCC_POTENTIAL_HOSTS="${DISTCC_HOSTS}"

pushd memcached-1.6.22

./configure --disable-docs

MAKEFLAGS="CC=distcc\ gcc" make -j2

popd
popd
