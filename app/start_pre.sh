#!/bin/bash

set -x

curl -L -o /usr/src/app/start.sh https://raw.githubusercontent.com/tshr20180821/render-09/main/start.sh
chmod +x /usr/src/app/start.sh
/usr/src/app/start.sh
