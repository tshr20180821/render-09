#!/bin/bash

set -x

apt-get -qq update
apt-get -q install -y curl iproute2 >/dev/null

mkdir -p /var/www/html/auth
a2dissite -q 000-default.conf

chown www-data:www-data /var/www/html/auth -R

echo '<HTML />' >/var/www/html/index.html


rm /usr/src/app/start.sh
curl -sSL -H 'Cache-Control: no-cache' -o /usr/src/app/start.sh https://raw.githubusercontent.com/tshr20180821/render-09/main/app/start.sh?$(date +%s)
cat /usr/src/app/start.sh
chmod +x /usr/src/app/start.sh
/usr/src/app/start.sh
