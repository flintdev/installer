#!/bin/sh
# wait-for-ui-install-builder.sh

set -e

cmd="$@"

until [ -f /application/dist/server.js ]; do
  >&2 echo "file server.js does not exsit"
  sleep 1
done

>&2 echo "server.js is ready"
exec $cmd