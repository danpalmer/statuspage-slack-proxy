FROM openresty/openresty:alpine-fat

COPY src/* /etc/nginx/
RUN cp /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.pem
RUN opm get ledgetech/lua-resty-http

EXPOSE 8080
CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
