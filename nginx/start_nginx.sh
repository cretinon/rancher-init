#!/bin/sh

docker run -d -p 80:80 -p 443:443 \
  --name nginx \
  -v /docker/nginx/conf.d:/etc/nginx/conf.d  \
  -v /docker/nginx/vhost.d:/etc/nginx/vhost.d \
  -v /docker/nginx/html:/usr/share/nginx/html \
  -v /docker/nginx/certs:/etc/nginx/certs:ro \
  --label com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy \
  nginx

docker run -d \
  --name nginx-gen \
  --volumes-from nginx \
  -v /docker/git_clone/rancher-init/nginx/nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro \
  -v /var/run/docker.sock:/tmp/docker.sock:ro \
  --label com.github.jrcs.letsencrypt_nginx_proxy_companion.docker_gen \
  jwilder/docker-gen \
  -notify-sighup nginx -watch -wait 5s:30s /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf

docker run -d \
  --name nginx-letsencrypt \
  --volumes-from nginx \
  -v /docker/nginx/certs:/etc/nginx/certs:rw \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  jrcs/letsencrypt-nginx-proxy-companion
