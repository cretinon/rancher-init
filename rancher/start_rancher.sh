#!/bin/sh

docker run -e VIRTUAL_PORT=8080 -e VIRTUAL_HOST=vps3.cretinon.fr -e LETSENCRYPT_HOST=vps3.cretinon.fr -e LETSENCRYPT_EMAIL=jacques@cretinon.fr -d --restart=unless-stopped --name=rancher-server -p 8080:8080 rancher/server
