#!/bin/bash

set -x

# sasl memcached
export MEMCACHED_SERVER=127.0.0.1
export MEMCACHED_PORT=11211
export MEMCACHED_USER=memcached
useradd ${MEMCACHED_USER} -G sasl
export SASL_PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 64 | head -n 1)
echo ${SASL_PASSWORD} | saslpasswd2 -p -a memcached -c memcached
chown "${MEMCACHED_USER}":memcached /etc/sasldb2
sasldblistusers2
export SASL_CONF_PATH=/tmp/memcached.conf
echo "mech_list: plain" >/tmp/memcached.conf
memcached --enable-sasl -v -l "${MEMCACHED_SERVER}" -P "${MEMCACHED_PORT}" -B binary -m 32 -t 3 -d -u "${MEMCACHED_USER}" -P /tmp/11211.tmp &

# build script

# curl -sSL -H 'Cache-Control: no-cache' -O https://github.com/tshr20180821/render-09/raw/main/build_memcached.sh

# cat /usr/src/app/build_memcached.sh
# chmod +x /usr/src/app/build_memcached.sh
# sleep 10s && /usr/src/app/build_memcached.sh &

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

curl -sSL -H 'Cache-Control: no-cache' -o /etc/apache2/sites-enabled/apache.conf https://github.com/tshr20180821/render-09/raw/main/apache.conf
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
