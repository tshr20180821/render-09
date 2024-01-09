#!/bin/bash

set -x

curl -sSL https://github.com/nwtgck/piping-server-pkg/releases/download/v1.12.9-1/piping-server-pkg-linuxstatic-x64.tar.gz | tar xzf -
./piping-server-pkg-linuxstatic-x64/piping-server --host=127.0.0.1 --http-port=8080 &

# curl -sSL https://github.com/nwtgck/piping-server-rust/releases/download/v0.16.0/piping-server-x86_64-unknown-linux-musl.tar.gz | tar xzf -
# ./piping-server-x86_64-unknown-linux-musl/piping-server --host=127.0.0.1 --http-port=8080 &

touch /var/www/html/auth/distccd_log.txt
chmod 666 /var/www/html/auth/distccd_log.txt
/usr/bin/distccd --port=3634 --listen=127.0.0.1 --user=nobody --jobs=4 --log-level=debug --log-file=/var/www/html/auth/distccd_log.txt --daemon

sleep 10s
ss -ant

# curl http://127.0.0.1:8080/help

# server
# POST : curl --data-binary @- https://hoge/hoge
# socat TCP-LISTEN:3634,bind=127.0.0.1,reuseaddr,fork 'EXEC:exec /usr/bin/distccd --log-level warning --log-file /var/www/html/auth/distccd_log.txt -'
# socat 'EXEC:curl -NsS https\://${RENDER_EXTERNAL_HOSTNAME}/piping/distccd_request!!EXEC:curl -NsST - https\://${RENDER_EXTERNAL_HOSTNAME}/piping/distccd_response' TCP:127.0.0.1:3634
# socat -dd "EXEC:curl -NsS https\://${RENDER_EXTERNAL_HOSTNAME}/piping/distccd_request!!EXEC:curl -NsST - https\://${RENDER_EXTERNAL_HOSTNAME}/piping/distccd_response" \
#   'EXEC:/usr/bin/distccd --user nobody --log-level debug --log-file /var/www/html/auth/distccd_log.txt -' &
socat -dd "EXEC:curl -NsS https\://${RENDER_EXTERNAL_HOSTNAME}/piping/distccd_request!!EXEC:curl -NsST - https\://${RENDER_EXTERNAL_HOSTNAME}/piping/distccd_response" \
  TCP:127.0.0.1:3634 &

# client
socat -dd -4 TCP-LISTEN:3632,bind=127.0.0.1,reuseaddr,fork \
  "EXEC:curl -NsS https\://${RENDER_EXTERNAL_HOSTNAME}/piping/distccd_response!!EXEC:curl -NsST - https\://${RENDER_EXTERNAL_HOSTNAME}/piping/distccd_request" &

sleep 3s
ss -ant
ps aux

apt-get -qq update
apt-get install -y libevent-dev >/dev/null 2>&1

pushd /tmp
curl -sSO https://memcached.org/files/memcached-1.6.22.tar.gz
tar xf memcached-1.6.22.tar.gz

export DISTCC_HOSTS="127.0.0.1/1 localhost/1"
export DISTCC_POTENTIAL_HOSTS="${DISTCC_HOSTS}"

pushd memcached-1.6.22

./configure --disable-docs >/dev/null

time MAKEFLAGS="CC=distcc\ gcc" make -j2

popd
popd

cat /var/www/html/auth/distccd_log.txt
