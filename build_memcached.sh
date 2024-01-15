#!/bin/bash

set -x

curl -sSLO https://github.com/nwtgck/go-piping-duplex/releases/download/v0.3.0-release-trigger2/piping-duplex-0.3.0-release-trigger2-linux-amd64.tar.gz
tar xf piping-duplex-0.3.0-release-trigger2-linux-amd64.tar.gz
chmod +x piping-duplex

mkdir ./.ssh
chmod 700 ./.ssh
curl -sS -u ${BASIC_USER}:${BASIC_PASSWORD} -o /usr/src/app/.ssh/ssh_host_rsa_key.pub ${SERVER01}/auth/ssh_host_rsa_key.pub.txt
KEYWORD=$(curl -sS -u ${BASIC_USER}:${BASIC_PASSWORD} ${SERVER01}/auth/keyword.txt)
export PIPING_SERVER=$(curl -sS -u ${BASIC_USER}:${BASIC_PASSWORD} ${SERVER01}/auth/piping_server.txt)

socat -4 tcp-listen:10022,bind=127.0.0.1,reuseaddr,fork "exec:./piping-duplex ${KEYWORD}sshd_response ${KEYWORD}sshd_request" &

cat << EOF >/usr/src/app/ssh_config
Host *
  StrictHostKeyChecking no
  Hostname 127.0.0.1
  IdentitiesOnly yes
  IdentityFile /usr/src/app/.ssh/ssh_host_rsa_key.pub
  UserKnownHostsFile /dev/null
  ControlMaster auto
  ControlPath /tmp/ssh_master-%r@%h:%p
  ControlPersist 120
  Compression yes
EOF

ssh2 -F /usr/src/app/ssh_config -p 10022 root@127.0.0.1 'ls -lang'
