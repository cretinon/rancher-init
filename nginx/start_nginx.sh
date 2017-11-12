#!/bin/sh

docker swarm init

docker service create \
    --name portainer \
    --publish 9000:9000 \
    --constraint 'node.role == manager' \
    --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
    --mount type=bind,src=/docker/portainer/dat,dst=/data \
    portainer/portainer \
    -H unix:///var/run/docker.sock

docker network create reverse-proxy

mkdir /docker/nginx/conf.d
mkdir /docker/nginx/vhost.d
mkdir /docker/nginx/html
mkdir /docker/nginx-proxy/ssl

docker-compose up

#docker run -d -p 80:80 -p 443:443 \
#  --name nginx \
#  --net reverse-proxy \
#  --restart unless-stopped \
#  -v /docker/nginx/conf.d:/etc/nginx/conf.d  \
#  -v /docker/nginx/vhost.d:/etc/nginx/vhost.d \
#  -v /docker/nginx/html:/usr/share/nginx/html \
#  -v /docker/nginx/certs:/etc/nginx/certs:ro \
#  --label com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy \
#  nginx

#docker run -d \
#  --name nginx-gen \
#  --net reverse-proxy \
#  --restart unless-stopped \
#  --volumes-from nginx \
#  -v /docker/git_clone/rancher-init/nginx/nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro \
#  -v /var/run/docker.sock:/tmp/docker.sock:ro \
#  --label com.github.jrcs.letsencrypt_nginx_proxy_companion.docker_gen \
#  jwilder/docker-gen \
#  -notify-sighup nginx -watch -wait 5s:30s /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf

#docker run -d \
#  --name nginx-letsencrypt \
#  --net reverse-proxy \
#  --restart unless-stopped \
#  --volumes-from nginx \
#  -v /docker/nginx/certs:/etc/nginx/certs:rw \
#  -v /var/run/docker.sock:/var/run/docker.sock:ro \
#  jrcs/letsencrypt-nginx-proxy-companion
