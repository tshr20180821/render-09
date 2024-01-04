#!/bin/bash

set -x

echo '<HTML />' >/var/www/html/index.html

for i in {1..6}; do \
  for j in {1..10}; do sleep 60s && echo "${i} ${j}"; done \
   && ss -anpt \
   && ps aux \
   && curl -sS -A "health check" https://"${RENDER_EXTERNAL_HOSTNAME}"/; \
done &

./build_memcached.sh &

. /etc/apache2/envvars
exec /usr/sbin/apache2 -DFOREGROUND
