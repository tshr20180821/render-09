#!/bin/bash

set -x

KEYWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)

DEBIAN_FRONTEND=noninteractive apt-get -qq install -y --no-install-recommends \
  build-essential \
  distcc \
  gcc-x86-64-linux-gnu \
  netcat-openbsd \
  socat \
  ssh \
  >/dev/null

curl -sSL https://github.com/nwtgck/piping-server-rust/releases/download/v0.16.0/piping-server-x86_64-unknown-linux-musl.tar.gz | tar xzf -
./piping-server-x86_64-unknown-linux-musl/piping-server --host=127.0.0.1 --http-port=8081 &

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
PasswordAuthentication yes
ChallengeResponseAuthentication no
PubkeyAuthentication yes
HostKey /usr/src/app/.ssh/ssh_host_rsa_key
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

echo "root:${KEYWORD}" | chpasswd

useradd --system --shell /usr/sbin/nologin --home=/run/hpnsshd hpnsshd
mkdir /var/empty

/app/hpnsshd -4De -f /usr/src/app/hpnsshd_config &

sleep 3s

curl -sSN https://${RENDER_EXTERNAL_HOSTNAME}/piping_rust/${KEYWORD}xxx | nc 127.0.0.1 10022 | curl -sSNT - https://${RENDER_EXTERNAL_HOSTNAME}/piping_rust/${KEYWORD}yyy &
