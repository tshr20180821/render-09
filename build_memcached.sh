#!/bin/bash

set -x

pwd

curl -sSL -H 'Cache-Control: no-cache' -o /var/www/html/auth/distccd.php https://github.com/tshr20180821/render-09/raw/main/auth/distccd.php
cat /var/www/html/auth/distccd.php

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
  ssh \
  >/dev/null

curl -sSLO https://raw.githubusercontent.com/tshr20180821/render-07/main/app/hpnsshd
chmod +x ./hpnsshd

mkdir ./.ssh
chmod 700 ./.ssh

ssh-keygen -t rsa -N '' -f ./.ssh/ssh_host_rsa_key

cat << EOF >/usr/src/app/hpnsshd_config
AddressFamily inet
ListenAddress 127.0.0.1:10022
Protocol 2
PermitRootLogin yes
PasswordAuthentication no
ChallengeResponseAuthentication no
PubkeyAuthentication yes
HostKey /app/.ssh/ssh_host_rsa_key
AuthorizedKeysFile /usr/src/app/.ssh/ssh_host_rsa_key.pub
X11Forwarding no
PrintMotd no
LogLevel VERBOSE
AcceptEnv LANG LC_*
PidFile /tmp/hpnsshd.pid
ClientAliveInterval 120
ClientAliveCountMax 3
Compression no
EOF

useradd --system --shell /usr/sbin/nologin --home=/run/hpnsshd hpnsshd
mkdir /var/empty

/usr/src/app/hpnsshd -4De -f /usr/src/app/hpnsshd_config &
cp ./.ssh/ssh_host_rsa_key.pub /var/www/html/auth/ssh_host_rsa_key.pub.txt

curl -sSLO https://github.com/nwtgck/go-piping-duplex/releases/download/v0.3.0-release-trigger2/piping-duplex-0.3.0-release-trigger2-linux-amd64.tar.gz
tar xf piping-duplex-0.3.0-release-trigger2-linux-amd64.tar.gz
chmod +x piping-duplex

socat -v -ddd "exec:./piping-duplex -s https\://${RENDER_EXTERNAL_HOSTNAME}/piping/ ${KEYWORD}sshd_request ${KEYWORD}sshd_response" tcp:127.0.0.1:10022 &

DISTCCD_LOG_FILE=/var/www/html/auth/distccd_log.txt
touch ${DISTCCD_LOG_FILE}
chmod 666 ${DISTCCD_LOG_FILE}

/usr/bin/distccd --port=13632 --listen=127.0.0.1 --user=nobody --jobs=4 --log-level=debug --log-file=${DISTCCD_LOG_FILE} --daemon --stats --stats-port=3633 --allow-private --job-lifetime=180 --nice=10

echo '***** socat *****'

# socat -ddd tcp-listen:3632,reuseaddr,fork 'exec:/tmp/sc01.sh' &
# socat -ddd tcp-listen:3632,reuseaddr,fork "exec:curl -u ${BASIC_USER}\:${BASIC_PASSWORD} --stderr /var/www/html/auth/stderr.txt -NT - https\://${RENDER_EXTERNAL_HOSTNAME}/auth/distccd.php" &

# socat -ddd -b 81920 tcp-listen:3632,bind=127.0.0.1,reuseaddr,fork,sndbuf=81920 \
#   "exec:curl --no-keepalive -N --tcp-nodelay --trace-time -u ${BASIC_USER}\:${BASIC_PASSWORD} --trace /var/www/html/auth/trace.txt --stderr /var/www/html/auth/stderr.txt --data-binary @- https\://${RENDER_EXTERNAL_HOSTNAME}/auth/distccd.php" &

# OK
# socat -ddd -b 81920 tcp-listen:3632,bind=127.0.0.1,reuseaddr,fork,sndbuf=81920 \
#   "exec:php /var/www/html/auth/distccd.php" &

socat -ddd -b 81920 tcp-listen:3632,bind=127.0.0.1,reuseaddr,fork,sndbuf=81920 \
  "exec:curl -N --tcp-nodelay --trace-time -u ${BASIC_USER}\:${BASIC_PASSWORD} --trace /var/www/html/auth/trace.txt --stderr /var/www/html/auth/stderr.txt --data-binary @- https\://${RENDER_EXTERNAL_HOSTNAME}/auth/distccd.php" &

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
export DISTCC_VERBOSE=1

pushd memcached-1.6.22

./configure --disable-docs >/dev/null

time MAKEFLAGS="CC=distcc\ gcc" make -j2

popd
popd

ls -lang /var/www/html/auth/
