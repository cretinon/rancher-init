#!/bin/sh

docker network create --driver=overlay --attachable wordpress-net ; docker stack deploy wordpress --compose-file docker-compose.yml

