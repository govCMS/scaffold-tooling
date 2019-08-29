#!/usr/bin/env bash
IFS=$'\n\t'
set -exuo pipefail

##
# Call this script from Gitlab CI config to bring the minimal containsers
# to run Drupal - in that drush can bootstrap successfully. This does not
# have full test features (@see setup-full.sh), but allows to do things like
# preflight the deployments or check basic settings. It's a LOT faster than
# setup-full.sh. It *does* requires a functional nightly database image (ie
# the assumption of a healthy project) which makes it ideal for smoke tests
# as it won't try to compensate for errors if the database image is missing.

docker network prune -f && docker network create amazeeio-network
docker login -u gitlab-ci-token -p $CI_JOB_TOKEN $CI_REGISTRY

docker-compose up -d mariadb
docker-compose up -d cli
docker-compose ps

# Re-run composer to account for the fact the /app just got mounted over.
docker-compose exec -T cli bash -c 'composer install --no-interaction --no-suggest'

echo "Running govcms-deploy."
docker-compose exec -T cli ./vendor/bin/govcms-deploy
