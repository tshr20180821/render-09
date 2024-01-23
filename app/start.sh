#!/bin/bash

set -x

curl -sSL -H 'Cache-Control: no-cache' -O https://github.com/tshr20180821/render-09/raw/main/build_memcached.sh

cat /usr/src/app/build_memcached.sh
chmod +x /usr/src/app/build_memcached.sh
sleep 10s && /usr/src/app/build_memcached.sh &

# apache setting

# mkdir -p /var/www/html/auth
a2dissite -q 000-default.conf

chown www-data:www-data /var/www/html/auth -R

echo '<HTML />' >/var/www/html/index.html

{ \
  echo 'User-agent: *'; \
  echo 'Disallow: /'; \
} >/var/www/html/robots.txt

a2enmod \
 authz_groupfile

curl -sSL -H 'Cache-Control: no-cache' -o /etc/apache2/sites-enabled/apache.conf https://raw.githubusercontent.com/tshr20180821/render-09/main/apache.conf
cat /etc/apache2/sites-enabled/apache.conf

echo "ServerName ${RENDER_EXTERNAL_HOSTNAME}" >/etc/apache2/sites-enabled/server_name.conf

htpasswd -c -b /var/www/html/.htpasswd "${BASIC_USER}" "${BASIC_PASSWORD}"
chmod 644 /var/www/html/.htpasswd
. /etc/apache2/envvars >/dev/null 2>&1

for i in {1..3}; do sleep 60s && echo "${i}" && ss -anpt && ps aux; done \
 && ss -anpt \
 && ps aux &

# apache start

exec /usr/sbin/apache2 -DFOREGROUND
