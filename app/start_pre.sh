#!/bin/bash

set -x

rm /usr/src/app/start.sh
curl -L -H 'Cache-Control: no-cache' -o /usr/src/app/start.sh https://raw.githubusercontent.com/tshr20180821/render-09/main/app/start.sh?$(date +%s)
cat /usr/src/app/start.sh
chmod +x /usr/src/app/start.sh
/usr/src/app/start.sh
