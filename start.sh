#!/bin/bash

set -x

curl -LO https://github.com/ginuerzh/gost/releases/download/v2.11.5/gost-linux-amd64-2.11.5.gz

gunzip gost-linux-amd64-2.11.5.gz

chmod +x gost-linux-amd64-2.11.5

./gost-linux-amd64-2.11.5 -L=:80
