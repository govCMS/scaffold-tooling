#!/usr/bin/env bash
IFS=$'\n\t'
set -exuo pipefail

docker network prune -f && docker network create amazeeio-network
docker login -u gitlab-ci-token -p $CI_JOB_TOKEN $DOCKER_REGISTRY

docker-compose up -d
docker-compose exec -T test dockerize -wait tcp://mariadb:3306 -timeout 1m

# A hack to make the manifest check work.
sed -i "s/^}$/,\"experimental\":\ \"enabled\"}/" ~/.docker/config.json
EXIT_CODE=0 && docker manifest inspect "testagain" || EXIT_CODE=$?

if [[ $EXIT_CODE -ne 0 ]]; then
    echo "$MARIADB_DATA_IMAGE not found, installing GovCMS"
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
    echo "Running govcms-deploy."
    docker-compose exec -T cli govcms-deploy
fi

docker-compose exec -T cli bash -c 'drush st'
