#!/bin/bash

set -x

echo '<HTML />' >/var/www/html/index.html

for i in {1..3}; do \
  for j in {1..3}; do sleep 60s && echo "${i} ${j}"; done \
   && ss -anpt \
   && ps aux \
   && curl -sS -A "health check" https://"${RENDER_EXTERNAL_HOSTNAME}"/; \
done &

#netcat --help
#nc -h
ncat --help

# distcc --help
# distccd --help

# nc -4kl 3632 -s 127.0.0.1 -e /usr/src/app/distccd_wrapper.sh &
# nc -lkp 3632 -s 127.0.0.1 -e /usr/src/app/distccd_wrapper.sh &
# strace -Ttt -s 1024 -e trace=network,read,write,poll,fcntl,open,close nc -lkp 3632 -s 127.0.0.1 -e /usr/src/app/distccd_wrapper.sh &

ncat --sh-exec "ncat -u 127.0.0.1 3632" -4nkl 127.0.0.1 3632 --no-shutdown --allow 127.0.0.1 &
ncat --sh-exec "/usr/src/app/distccd_wrapper.sh" -4ukl 127.0.0.1 3632 --no-shutdown --allow 127.0.0.1 &

sleep 5s && ss -anpto && ps aux &

sleep 10s && ./build_memcached.sh &

. /etc/apache2/envvars
exec /usr/sbin/apache2 -DFOREGROUND
