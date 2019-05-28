#!/usr/bin/env sh
set -eu
envsubst '${PORT}' < /usr/local/openresty/nginx/conf/app.conf > /usr/local/openresty/nginx/conf/app.conf.sub
exec "$@"
