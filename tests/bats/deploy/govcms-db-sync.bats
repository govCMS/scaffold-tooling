#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030

load ../_helpers_govcms

################################################################################
#                               DEFAULTS                                       #
################################################################################

@test "Database sync: defaults" {
  mock_drush=$(mock_command "drush")

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
  mock_set_output "${mock_drush}" "Successful" 1

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
  assert_output_contains "[info]: Alias path:       /etc/drush/sites"

  assert_output_contains "[info]: Check that the site can be bootstrapped."
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 1)"

  assert_output_contains "[skip]: Site can be bootstrapped and the content workflow is not set to \"import\"."
  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"
}

@test "Database sync: development, no existing site" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Failed" 1

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
  assert_output_contains "[info]: Alias path:       /etc/drush/sites"

  assert_output_contains "[info]: Check that the site can be bootstrapped."
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_output_contains "[info]: Site could not be bootstrapped... syncing."

  assert_output_contains "[info]: Preparing database sync"
  assert_equal "--alias-path=/etc/drush/sites sql:sync @govcms.prod @self -y" "$(mock_get_call_args "${mock_drush}" 2)"

  assert_output_contains "[success]: Completed successfully."
  assert_equal 2 "$(mock_get_call_num "${mock_drush}")"
}

@test "Database sync: development, alias overrides" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 1

  export LAGOON_ENVIRONMENT_TYPE=development
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=import
  export GOVCMS_SITE_ALIAS=govcms.override
  export GOVCMS_SITE_ALIAS_PATH=/etc/drush/othersites
  export MARIADB_READREPLICA_HOSTS=

  run scripts/deploy/govcms-db-sync >&3

  assert_output_contains "GovCMS Deploy :: Database synchronisation"

  assert_output_contains "[info]: Environment type: development"
  assert_output_contains "[info]: Content strategy: import"
  assert_output_contains "[info]: Site alias:       govcms.override"
  assert_output_contains "[info]: Alias path:       /etc/drush/othersites"

  assert_output_contains "[info]: Check that the site can be bootstrapped."
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 1)"

  assert_output_contains "[info]: Preparing database sync"
  assert_equal "--alias-path=/etc/drush/othersites sql:sync @govcms.override @self -y" "$(mock_get_call_args "${mock_drush}" 2)"

  assert_output_contains "[success]: Completed successfully."
  assert_equal 2 "$(mock_get_call_num "${mock_drush}")"
}

@test "Database sync: development, import content" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 1

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
  assert_output_contains "[info]: Alias path:       /etc/drush/sites"

  assert_output_contains "[info]: Check that the site can be bootstrapped."
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 1)"

  assert_output_contains "[info]: Preparing database sync"
  assert_equal "--alias-path=/etc/drush/sites sql:sync @govcms.prod @self -y" "$(mock_get_call_args "${mock_drush}" 2)"

  assert_output_contains "[success]: Completed successfully."
  assert_equal 2 "$(mock_get_call_num "${mock_drush}")"
}

@test "Database sync: development, import content, db replica available" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 1
  mock_set_output "${mock_drush}" "table1\ntable2" 2

  export LAGOON_ENVIRONMENT_TYPE=development
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=import
  export GOVCMS_SITE_ALIAS=
  export GOVCMS_SITE_ALIAS_PATH=
  export MARIADB_READREPLICA_HOSTS="dbreplicahost1 dbreplicahost2"

  run scripts/deploy/govcms-db-sync >&3

  assert_output_contains "GovCMS Deploy :: Database synchronisation"

  assert_output_contains "[info]: Environment type: development"
  assert_output_contains "[info]: Content strategy: import"
  assert_output_contains "[info]: Site alias:       govcms.prod"
  assert_output_contains "[info]: Alias path:       /etc/drush/sites"

  assert_output_contains "[info]: Check that the site can be bootstrapped."
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 1)"

  assert_output_contains "[info]: Preparing database sync"
  assert_equal "@govcms.prod sqlq show tables; --database=read" "$(mock_get_call_args "${mock_drush}" 2)"
  assert_output_contains "[info]: Replica is available, using for database operations."
  assert_equal "--alias-path=/etc/drush/sites --source-database=read sql:sync @govcms.prod @self -y" "$(mock_get_call_args "${mock_drush}" 3)"

  assert_output_contains "[success]: Completed successfully."
  assert_equal 3 "$(mock_get_call_num "${mock_drush}")"
}
