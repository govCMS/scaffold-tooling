#!/usr/bin/env bash
IFS=$'\n\t'
set -exuo pipefail

docker network prune -f && docker network create amazeeio-network
docker login -u gitlab-ci-token -p $CI_JOB_TOKEN $DOCKER_REGISTRY

composer install
docker-compose up -d test
