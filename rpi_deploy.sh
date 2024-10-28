#!/bin/bash

set -eu

if [ -z $1 ]; then
  echo "Error: No server specified!"
  echo "USAGE: ./rpi_deploy.sh username@host"
  exit 1
fi

server=$1

echo "Building image"
docker buildx build --platform linux/arm64/v8 --load -f docker/Dockerfile -t kwalter94/khodo:latest .
docker save -o khodo.img kwalter94/khodo:latest

echo "Copying image to pi"
ssh $server "[ -d khodo ] || mkdir khodo"
rsync --progress khodo.img docker-compose-prod.yml $server:khodo/
ssh $server "cd khodo && docker load -i khodo.img && docker-compose -f docker-compose-prod.yml restart"
rm khodo.img

echo "Update done"
