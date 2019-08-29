#!/usr/bin/env bash
IFS=$'\n\t'
set -exuo pipefail

##
# Call this script to have `test` only, capable of static testing like linting.

docker network prune -f && docker network create amazeeio-network
docker login -u gitlab-ci-token -p $CI_JOB_TOKEN $CI_REGISTRY

docker-compose up -d test
docker-compose ps

# Re-run composer to account for the fact the /app just got mounted over.
docker-compose exec -T cli bash -c 'composer install --no-interaction --no-suggest'
