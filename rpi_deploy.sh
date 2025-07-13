#!/bin/bash

set -eu

if [ -z $1 ]; then
  echo "Error: No server specified!"
  echo "USAGE: ./rpi_deploy.sh username@host"
  exit 1
fi

server=$1
version=v$(shards version)

echo "Building image..."
docker buildx build --platform linux/arm64/v8 --load -f docker/Dockerfile -t kwalter94/khodo:latest -t kwalter94/khodo:$version .
docker save -o khodo-$version.img kwalter94/khodo:$version kwalter94/khodo:latest

echo "Copying image to pi..."
eval "$(ssh-agent -s)"
ssh-add

ssh $server "[ -d khodo ] || mkdir khodo"
rsync --progress -r khodo-$version.img docker-compose-prod.yml docker $server:khodo/
ssh $server <<-sh
  set -x

  cd ~/khodo
  docker load -i khodo-${version}.img
  TAG=${version} docker-compose -f docker-compose-prod.yml up --wait --remove-orphans --detach
  TAG=${version} docker-compose -f docker-compose-prod.yml exec --no-tty postgres /docker-entrypoint-initdb.d/create-reporting-user.sh
  TAG=${version} docker-compose -f docker-compose-prod.yml restart --no-deps postgres
  rm -f khodo-${version}.img
sh

rm -f khodo-$version.img

echo "Update done"
