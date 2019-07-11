#!/usr/bin/env bash

# Set up the dependencies for running full bootstrap tests in the lagoon container.

copy .env.default .env
export DOCKER_HOST=tcp://localhost:2375
docker network prune -f && docker network create amazeeio-network
docker login -u gitlab-ci-token -p $CI_JOB_TOKEN gitlab-registry-production.govcms.amazee.io
docker-compose up -d
docker-compose exec -T test dockerize -wait tcp://mariadb:3306 -timeout 1m

if grep --quiet '^MARIADB_DATA_IMAGE' .env; then
 ahoy -v lagoon govcms-deploy
else
 ahoy -v govcms composer install
 ahoy -v govcms install
fi
