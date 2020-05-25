#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030

load ../_helpers_govcms

################################################################################
#                               DEFAULTS                                       #
################################################################################

@test "Database backup: defaults" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 1

  export LAGOON_ENVIRONMENT_TYPE=
  export GOVCMS_BACKUP_DIR=

  export APP

  run scripts/deploy/govcms-db-backup >&3
  assert_success

  assert_output_contains "GovCMS Deploy :: Backup database"

  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 1)"

  assert_dir_exists "$APP/web/sites/default/files/private/backups"

  assert_equal "sql:dump --gzip --result-file=$APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" "$(mock_get_call_args "${mock_drush}" 2)"

  assert_output_contains "[info]: Backup saved to $APP/web/sites/default/files/private/backups/pre-deploy-dump.sql."
  assert_output_contains "[success]: Completed successfully."
}


################################################################################
#                               NON-PROD                                       #
################################################################################

@test "Database backup: non-production" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 1

  export LAGOON_ENVIRONMENT_TYPE=development
  export GOVCMS_BACKUP_DIR=

  export APP

  run scripts/deploy/govcms-db-backup >&3
  assert_success

  assert_output_contains "GovCMS Deploy :: Backup database"
  assert_output_contains "[skip]: Non-production environment."
}

################################################################################
#                            FAILED BOOTSTRAP                                  #
################################################################################

@test "Database backup: failed bootstrap" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Failed!" 1

  export LAGOON_ENVIRONMENT_TYPE=
  export GOVCMS_BACKUP_DIR=

  export APP

  run scripts/deploy/govcms-db-backup >&3
  assert_success

  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 1)"

  assert_output_contains "GovCMS Deploy :: Backup database"
  assert_output_contains "[fail]: Drupal is not installed or operational."
}

################################################################################
#                            CHANGED DIRECTORY                                 #
################################################################################

@test "Database backup: non-standard directory" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Failed!" 1

  export LAGOON_ENVIRONMENT_TYPE=
  export GOVCMS_BACKUP_DIR=/tmp/backup

  export APP

  run scripts/deploy/govcms-db-backup >&3
  assert_success

  assert_output_contains "GovCMS Deploy :: Backup database"

  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 1)"

  assert_dir_exists "/tmp/backup"

  assert_output_contains "[info]: Backup saved to /tmp/backup/pre-deploy-dump.sql."
  assert_output_contains "[success]: Completed successfully."
}

################################################################################
#                              READ REPLICA                                    #
################################################################################

@test "Database backup: replica supported" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 1

  export LAGOON_ENVIRONMENT_TYPE=
  export GOVCMS_BACKUP_DIR=
  export MARIADB_READREPLICA_HOSTS="dbreplicahost1"

  export APP

  run scripts/deploy/govcms-db-backup >&3
  assert_success

  assert_output_contains "GovCMS Deploy :: Backup database"

  assert_equal "status" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 1)"

  assert_equal "sqlq show tables; --database=read" "$(mock_get_call_args "${mock_drush}" 2)"

  assert_output_contains "[info]: Replica is available, using for database operations."

  assert_dir_exists "$APP/web/sites/default/files/private/backups"

  assert_equal "sql:dump --gzip --result-file=$APP/web/sites/default/files/private/backups/pre-deploy-dump.sql --database=read" "$(mock_get_call_args "${mock_drush}" 3)"

  assert_output_contains "[info]: Backup saved to $APP/web/sites/default/files/private/backups/pre-deploy-dump.sql."
  assert_output_contains "[success]: Completed successfully."
}
