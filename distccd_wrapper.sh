#!/bin/bash

set -e

echo "$@"

# filename=$(mktemp $(date +'%Y%m%d%H%M%S').XXXXXX.dat)

# echo -n "$@" | base64 >${filename}

# echo -n $(gzip -c ${filename} | curl -X POST --data-binary @- -H "Content-Encoding: gzip" --compressed https://${RENDER_EXTERNAL_HOSTNAME}/distcc_wrapper.php) | base64 -d

# rm ${filename}
