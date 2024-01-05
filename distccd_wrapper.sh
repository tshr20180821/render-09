#!/bin/bash

set -e

echo "START distccd_wrapper.sh" >&2

filename=$(mktemp $(date +'%Y%m%d%H%M%S').XXXXXX.dat)

echo ${filename} >&2

echo -n "$@" | base64 >${filename}

ls -lang ${filename} >&2

echo -n $(gzip -c ${filename} | curl -X POST --data-binary @- -H "Content-Encoding: gzip" --compressed https://${RENDER_EXTERNAL_HOSTNAME}/distcc_wrapper.php) | base64 -d

rm ${filename}

echo "FINISH distccd_wrapper.sh" >&2
