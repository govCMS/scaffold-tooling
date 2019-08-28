#!/usr/bin/env bash
IFS=$'\n\t'
set -exuo pipefail

##
# Call this script from Gitlab CI config to bring up all containers,
# and deploy, resulting in a full functional up-to-date site. It's
# the slowest setup, but you can run behat and other complex tests.
#

docker network prune -f && docker network create amazeeio-network
docker login -u gitlab-ci-token -p $CI_JOB_TOKEN $CI_REGISTRY

docker-compose up -d mariadb
docker-compose up -d
docker-compose ps

# Re-run composer to account for the fact the /app just got mounted over, but caches should be warm.
docker-compose exec -T cli bash -c 'composer install --quiet'

DATABASE_IMAGE="$CI_REGISTRY_IMAGE/mariadb-drupal-data"

# A hack to make the manifest check work.
sed -i "s/^}$/,\"experimental\":\ \"enabled\"}/" ~/.docker/config.json
EXIT_CODE=0 && docker manifest inspect "$DATABASE_IMAGE" > /dev/null || EXIT_CODE=$?

if [[ $EXIT_CODE -ne 0 ]]; then
    echo "$DATABASE_IMAGE not found, installing GovCMS"
    docker-compose exec -T cli bash -c 'drush sql-drop'
    if [[ -f "./custom/database-quickstart.sql.gz" ]]; then
        echo "Installing from a database dump."
        gunzip ./custom/database-quickstart.sql.gz
        docker-compose exec -T cli bash -c 'drush sql-cli --yes' < ./custom/database-quickstart.sql
    else
        echo "Installing the default govcms profile."
        docker-compose exec -T cli bash -c 'drush si govcms -y'
    fi
else
    echo "Using found database image: $DATABASE_IMAGE"
fi

echo "Running govcms-deploy."
docker-compose exec -T cli ./vendor/bin/govcms-deploy
docker-compose exec -T cli bash -c 'drush st'
