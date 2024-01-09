#!/bin/bash

set -x

rm /etc/apache2/sites-enabled/apache.conf
curl -L -H 'Cache-Control: no-cache' -o /etc/apache2/sites-enabled/apache.conf https://raw.githubusercontent.com/tshr20180821/render-09/main/apache.conf?$(date +%s)
cat /etc/apache2/sites-enabled/apache.conf

curl -L -H 'Cache-Control: no-cache' -o /usr/src/app/build_memcached.sh https://raw.githubusercontent.com/tshr20180821/render-09/main/build_memcached.sh?$(date +%s)
cat /usr/src/app/build_memcached.sh
chmod +x /usr/src/app/build_memcached.sh
sleep 10s && /usr/src/app/build_memcached.sh &

# apache start
htpasswd -c -b /var/www/html/.htpasswd "${BASIC_USER}" "${BASIC_PASSWORD}"
chmod 644 /var/www/html/.htpasswd
. /etc/apache2/envvars >/dev/null 2>&1
exec /usr/sbin/apache2 -DFOREGROUND
