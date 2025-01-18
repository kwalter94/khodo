#!/bin/bash

set -eu

if [ -z $1 ]; then
  echo "Error: No server specified!"
  echo "USAGE: ./rpi_deploy.sh username@host"
  exit 1
fi

server=$1
version=v$(shards version)

echo "Building image"
docker buildx build --platform linux/arm64/v8 --load -f docker/Dockerfile -t kwalter94/khodo:latest -t kwalter94/khodo:$version .
docker save -o khodo-$version.img kwalter94/khodo:$version kwalter94/khodo:latest

echo "Copying image to pi"
ssh $server "[ -d khodo ] || mkdir khodo"
rsync --progress khodo-$version.img docker-compose-prod.yml $server:khodo/
ssh $server "cd khodo && docker load -i khodo-$version.img && TAG=$version docker-compose -f docker-compose-prod.yml up --wait --detach && rm khodo-$version.img"
rm khodo-$version.img

echo "Update done"
