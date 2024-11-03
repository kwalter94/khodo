#!/bin/sh

mkdir -p ~/khodo
cd ~/khodo
echo "SECRET_KEY=$(openssl rand -base64 40)" > .env
curl -L https://gitlab.com/ntumbuka/khodo/-/raw/develop/docker-compose-prod.yml?ref_type=heads -o docker-compose.yml
docker compose up
