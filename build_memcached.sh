#!/bin/bash

set -x

# apt-get -qq update
# apt-get install -y distcc proxytunnel socat ssh >/dev/null 2>&1
apt-get install -y distcc socat >/dev/null 2>&1

# start sshd

curl -Lo /usr/src/app/hpnsshd https://raw.githubusercontent.com/tshr20180821/render-07/main/app/hpnsshd
chmod +x /usr/src/app/hpnsshd

mkdir -p /usr/src/app/.ssh
chmod 700 /usr/src/app/.ssh

# ssh-keygen -t rsa -N '' -f /usr/src/app/.ssh/ssh_host_rsa_key

cat << EOF >/usr/src/app/hpnsshd_config
AddressFamily inet
ListenAddress 0.0.0.0
Protocol 2
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile /usr/src/app/.ssh/ssh_host_rsa_key.pub
X11Forwarding no
PrintMotd no
# LogLevel DEBUG3
LogLevel VERBOSE
AcceptEnv LANG LC_*
PidFile /tmp/hpnsshd.pid
ClientAliveInterval 120
ClientAliveCountMax 3
EOF

# useradd --system --shell /usr/sbin/nologin --home=/run/hpnsshd hpnsshd
# mkdir /var/empty

# /usr/src/app/hpnsshd -4Dp 60022 -h /usr/src/app/.ssh/ssh_host_rsa_key -f /usr/src/app/hpnsshd_config &
# cp /usr/src/app/.ssh/ssh_host_rsa_key.pub /var/www/html/auth/ssh_host_rsa_key.pub.txt

# finish sshd

# start piping server
# curl -sSL https://github.com/nwtgck/piping-server-pkg/releases/download/v1.12.9-1/piping-server-pkg-linuxstatic-x64.tar.gz | tar xzf -
# ./piping-server-pkg-linuxstatic-x64/piping-server --host=127.0.0.1 --http-port=8080 &

# curl -sSL https://github.com/nwtgck/piping-server-rust/releases/download/v0.16.0/piping-server-x86_64-unknown-linux-musl.tar.gz | tar xzf -
# ./piping-server-x86_64-unknown-linux-musl/piping-server --host=127.0.0.1 --http-port=8080 &

# finish piping server

# start distccd

touch /var/www/html/auth/distccd_log.txt
chmod 666 /var/www/html/auth/distccd_log.txt
# /usr/bin/distccd --nice=20 --port=3634 --listen=0.0.0.0 --user=nobody --jobs=4 --log-level=debug --log-file=/var/www/html/auth/distccd_log.txt --daemon
/usr/bin/distccd --port=3634 --listen=127.0.0.1 --user=nobody --jobs=1 --log-level=debug --log-file=/var/www/html/auth/distccd_log.txt --daemon

# finish distccd

sleep 10s
ss -ant

# start piping-duplex

curl -sSLO https://github.com/nwtgck/go-piping-duplex/releases/download/v0.3.0-release-trigger2/piping-duplex-0.3.0-release-trigger2-linux-amd64.tar.gz
tar xf piping-duplex-0.3.0-release-trigger2-linux-amd64.tar.gz
chmod +x piping-duplex

# finish piping-duplex

# curl http://127.0.0.1:8080/help

# start socat

KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)

# server
# POST : curl --data-binary @- https://hoge/hoge
# socat TCP-LISTEN:3634,bind=127.0.0.1,reuseaddr,fork 'EXEC:exec /usr/bin/distccd --log-level warning --log-file /var/www/html/auth/distccd_log.txt -'
# socat 'EXEC:curl -NsS https\://${RENDER_EXTERNAL_HOSTNAME}/piping/distccd_request!!EXEC:curl -NsST - https\://${RENDER_EXTERNAL_HOSTNAME}/piping/distccd_response' TCP:127.0.0.1:3634
# socat -dd "EXEC:curl -NsS https\://${RENDER_EXTERNAL_HOSTNAME}/piping/distccd_request!!EXEC:curl -NsST - https\://${RENDER_EXTERNAL_HOSTNAME}/piping/distccd_response" \
#   'EXEC:/usr/bin/distccd --user nobody --log-level debug --log-file /var/www/html/auth/distccd_log.txt -' &
# socat -ddd -vvv "EXEC:curl --http1.1 -NsS https\://${RENDER_EXTERNAL_HOSTNAME}/piping/distccd_request!!EXEC:curl --http1.1 -vNsST - https\://${RENDER_EXTERNAL_HOSTNAME}/piping/distccd_response" \
#   TCP:127.0.0.1:3634 &
# socat -ddd -v "EXEC:./piping-duplex -s https\://${RENDER_EXTERNAL_HOSTNAME}/piping distccd_request distccd_response" tcp:127.0.0.1:3634
socat "EXEC:./piping-duplex ${KEYWORD}distccd_request ${KEYWORD}distccd_response" tcp:127.0.0.1:3634 &

# client
# socat -4 tcp-listen:3632,bind=0.0.0.0,reuseaddr,fork \
#   "EXEC:curl --http1.1 -vNsS https\://${RENDER_EXTERNAL_HOSTNAME}/piping/distccd_response!!EXEC:curl --http1.1 -NsST - https\://${RENDER_EXTERNAL_HOSTNAME}/piping/distccd_request" &
# socat -ddd -4 -x tcp-listen:3632 "EXEC:./piping-duplex -s https\://${RENDER_EXTERNAL_HOSTNAME}/piping distccd_response distccd_request"
socat -4 tcp-listen:3632,reuseaddr,fork "EXEC:./piping-duplex ${KEYWORD}distccd_response ${KEYWORD}distccd_request" &

# finish socat

sleep 3s
ss -ant
ps aux

apt-get install -y libevent-dev >/dev/null 2>&1

pushd /tmp
curl -sSO https://memcached.org/files/memcached-1.6.22.tar.gz
tar xf memcached-1.6.22.tar.gz

# export DISTCC_VERBOSE=1
# export DISTCC_HOSTS="127.0.0.1/1,cpp,lzo localhost/1"
export DISTCC_HOSTS="127.0.0.1"
export DISTCC_POTENTIAL_HOSTS="${DISTCC_HOSTS}"

pushd memcached-1.6.22

./configure --disable-docs >/dev/null

time MAKEFLAGS="CC=distcc\ gcc" make -j1

popd
popd

cat /var/www/html/auth/distccd_log.txt
