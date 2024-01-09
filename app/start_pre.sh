#!/bin/bash

set -x

curl -L -H 'Cache-Control: no-cache' -o /usr/src/app/start.sh https://raw.githubusercontent.com/tshr20180821/render-09/main/app/start.sh?$(date +%s)
chmod +x /usr/src/app/start.sh
/usr/src/app/start.sh
