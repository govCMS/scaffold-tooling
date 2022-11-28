#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030,SC2034,SC2155

load ../_helpers_govcms

setup() {
  CUR_DIR="$PWD"
  export TEST_APP_DIR=$(prepare_app_dir)
  setup_mock

  touch /tmp/sync.sql.gz
}

################################################################################
#                               DEFAULTS                                       #
################################################################################

@test "Database sync: defaults" {
  mock_drush=$(mock_command "drush")
  mock_gunzip=$(mock_command "gunzip")

  export LAGOON_ENVIRONMENT_TYPE=
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=
  export GOVCMS_SITE_ALIAS=
  export GOVCMS_SITE_ALIAS_PATH=
  export MARIADB_READREPLICA_HOSTS=

  run scripts/deploy/govcms-db-sync >&3

  assert_output_contains "GovCMS Deploy :: Database synchronisation"

  assert_output_contains "[skip]: Production environment can't be synced."
  assert_equal 0 "$(mock_get_call_num "${mock_drush}")"
}

################################################################################
#                               PRODUCTION                                     #
################################################################################

@test "Database sync: production" {
  mock_drush=$(mock_command "drush")
  mock_gunzip=$(mock_command "gunzip")

  export LAGOON_ENVIRONMENT_TYPE=production
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=
  export GOVCMS_SITE_ALIAS=
  export GOVCMS_SITE_ALIAS_PATH=
  export MARIADB_READREPLICA_HOSTS=

  run scripts/deploy/govcms-db-sync >&3

  assert_output_contains "GovCMS Deploy :: Database synchronisation"

  assert_output_contains "[skip]: Production environment can't be synced."
  assert_equal 0 "$(mock_get_call_num "${mock_drush}")"
}

################################################################################
#                               DEVELOPMENT                                    #
################################################################################

@test "Database sync: development" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1

  export LAGOON_ENVIRONMENT_TYPE=development
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=
  export GOVCMS_SITE_ALIAS=
  export GOVCMS_SITE_ALIAS_PATH=
  export MARIADB_READREPLICA_HOSTS=

  run scripts/deploy/govcms-db-sync >&3

  assert_output_contains "GovCMS Deploy :: Database synchronisation"

  assert_output_contains "[info]: Environment type: development"
  assert_output_contains "[info]: Content strategy: retain"
  assert_output_contains "[info]: Site alias:       govcms.prod"
  assert_output_contains "[info]: Alias path:       /app/drush/sites"

  assert_output_contains "[info]: Check that the site can be bootstrapped."
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 1)"

  assert_output_contains "[skip]: Site can be bootstrapped and the content workflow is not set to \"import\"."
  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"
}

@test "Database sync: development, no existing site" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Failed" 1
  mock_gunzip=$(mock_command "gunzip")

  export LAGOON_ENVIRONMENT_TYPE=development
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=import
  export GOVCMS_SITE_ALIAS=
  export GOVCMS_SITE_ALIAS_PATH=
  export MARIADB_READREPLICA_HOSTS=

  run scripts/deploy/govcms-db-sync >&3

  assert_output_contains "GovCMS Deploy :: Database synchronisation"

  assert_output_contains "[info]: Environment type: development"
  assert_output_contains "[info]: Content strategy: import"
  assert_output_contains "[info]: Site alias:       govcms.prod"
  assert_output_contains "[info]: Alias path:       /app/drush/sites"

  assert_output_contains "[info]: Check that the site can be bootstrapped."
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_output_contains "[info]: Site could not be bootstrapped... syncing."

  assert_output_contains "[info]: Preparing database sync"
  assert_equal "--alias-path=/app/drush/sites @govcms.prod sql:dump --gzip --extra-dump=--no-tablespaces --result-file=/tmp/sync.sql -y" "$(mock_get_call_args "${mock_drush}" 2)"

  assert_output_contains "[success]: Completed successfully."
  assert_equal 4 "$(mock_get_call_num "${mock_drush}")"
}

@test "Database sync: development, alias overrides" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1
  mock_gunzip=$(mock_command "gunzip")

  export LAGOON_ENVIRONMENT_TYPE=development
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=import
  export GOVCMS_SITE_ALIAS=govcms.override
  export GOVCMS_SITE_ALIAS_PATH=/app/drush/othersites
  export MARIADB_READREPLICA_HOSTS=

  run scripts/deploy/govcms-db-sync >&3

  assert_output_contains "GovCMS Deploy :: Database synchronisation"

  assert_output_contains "[info]: Environment type: development"
  assert_output_contains "[info]: Content strategy: import"
  assert_output_contains "[info]: Site alias:       govcms.override"
  assert_output_contains "[info]: Alias path:       /app/drush/othersites"

  assert_output_contains "[info]: Check that the site can be bootstrapped."
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 1)"

  assert_output_contains "[info]: Preparing database sync"
  assert_equal "--alias-path=/app/drush/othersites @govcms.override sql:dump --gzip --extra-dump=--no-tablespaces --result-file=/tmp/sync.sql -y" "$(mock_get_call_args "${mock_drush}" 2)"

  assert_output_contains "[success]: Completed successfully."
  assert_equal 4 "$(mock_get_call_num "${mock_drush}")"
}

@test "Database sync: development, import content" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1
  mock_gunzip=$(mock_command "gunzip")

  export LAGOON_ENVIRONMENT_TYPE=development
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=import
  export GOVCMS_SITE_ALIAS=
  export GOVCMS_SITE_ALIAS_PATH=
  export MARIADB_READREPLICA_HOSTS=

  run scripts/deploy/govcms-db-sync >&3

  assert_output_contains "GovCMS Deploy :: Database synchronisation"

  assert_output_contains "[info]: Environment type: development"
  assert_output_contains "[info]: Content strategy: import"
  assert_output_contains "[info]: Site alias:       govcms.prod"
  assert_output_contains "[info]: Alias path:       /app/drush/sites"

  assert_output_contains "[info]: Check that the site can be bootstrapped."
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 1)"

  assert_output_contains "[info]: Preparing database sync"
  assert_equal "--alias-path=/app/drush/sites @govcms.prod sql:dump --gzip --extra-dump=--no-tablespaces --result-file=/tmp/sync.sql -y" "$(mock_get_call_args "${mock_drush}" 2)"

  assert_output_contains "[success]: Completed successfully."
  assert_equal 4 "$(mock_get_call_num "${mock_drush}")"
}

@test  "Database sync: always sync upgrade environments" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1
  mock_gunzip=$(mock_command "gunzip")
  mock_gunzip=$(mock_command "gunzip")

  export LAGOON_ENVIRONMENT_TYPE=development
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=
  export GOVCMS_SITE_ALIAS=
  export GOVCMS_SITE_ALIAS_PATH=
  export MARIADB_READREPLICA_HOSTS=
  export LAGOON_GIT_SAFE_BRANCH=internal-govcms-update-2-x-master

  run scripts/deploy/govcms-db-sync >&3

  assert_output_contains "GovCMS Deploy :: Database synchronisation"

  assert_output_contains "[info]: Environment type: development"
  assert_output_contains "[info]: Content strategy: retain"
  assert_output_contains "[info]: Site alias:       govcms.prod"
  assert_output_contains "[info]: Alias path:       /app/drush/sites"

  assert_output_contains "[info]: Check that the site can be bootstrapped."
  assert_output_contains "[info]: Upgrade branch... syncing."

  assert_output_contains "[info]: Preparing database sync"
  assert_equal "--alias-path=/app/drush/sites @govcms.prod sql:dump --gzip --extra-dump=--no-tablespaces --result-file=/tmp/sync.sql -y" "$(mock_get_call_args "${mock_drush}" 1)"

  assert_output_contains "[success]: Completed successfully."
  assert_equal 3 "$(mock_get_call_num "${mock_drush}")"
}
