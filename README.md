```shell
docker run \
    --rm \
    -v $PWD/src:/usr/local/openresty/nginx/conf/ \
    -v $PWD/static:/usr/local/static/ \
    -p 8080:80 \
    openresty/openresty:alpine
```
