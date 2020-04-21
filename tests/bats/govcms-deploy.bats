#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030

load _helpers_govcms

################################################################################
#                               DEFAULTS                                       #
################################################################################

@test "Defaults, no config" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 2
  mock_set_side_effect "${mock_drush}" "mkdir -p $APP/web/sites/default/files/private/backups && touch $APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" 3

  # Remove any values set in the current environment.
  export LAGOON_ENVIRONMENT_TYPE=
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=
  export APP

  assert_dir_not_exists "$APP/web/sites/default/files/private/tmp"

  run "$CUR_DIR"/scripts/govcms-deploy
  assert_success

  assert_output_contains "Running govcms-deploy"
  assert_output_contains "Environment type: production"
  assert_output_contains "Config strategy:  import"
  assert_output_contains "Content strategy: retain"
  assert_output_contains "There are 0 config yaml files, and 0 dev yaml files."

  assert_dir_exists "$APP/web/sites/default/files/private/tmp"

  # Bootstrap.
  assert_equal "core:status" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 2)"

  # Database backup.
  assert_output_contains "Making a database backup."
  assert_dir_exists "$APP/web/sites/default/files/private/backups"
  assert_equal "sql:dump --gzip --result-file=$APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" "$(mock_get_call_args "${mock_drush}" 3)"

  # Common deploy.
  assert_output_not_contains "Performing content import."

  assert_equal "updatedb -y" "$(mock_get_call_args "${mock_drush}" 4)"
  assert_equal "cache:rebuild" "$(mock_get_call_args "${mock_drush}" 5)"

  assert_output_not_contains "Performing config import."
  assert_output_not_contains "Performing development config import on non-production site."
  assert_output_not_contains "Enable stage_file_proxy in non-prod environments."

  assert_output_contains "Finished running govcms-deploy."
}

@test "Defaults, no config, not installed" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Failed" 2
  mock_set_side_effect "${mock_drush}" "mkdir -p $APP/web/sites/default/files/private/backups && touch $APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" 3

  # Remove any values set in the current environment.
  export LAGOON_ENVIRONMENT_TYPE=
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=
  export APP

  assert_dir_not_exists "$APP/web/sites/default/files/private/tmp"

  run "$CUR_DIR"/scripts/govcms-deploy
  assert_success

  assert_output_contains "Running govcms-deploy"
  assert_output_contains "Environment type: production"
  assert_output_contains "Config strategy:  import"
  assert_output_contains "Content strategy: retain"
  assert_output_contains "There are 0 config yaml files, and 0 dev yaml files."

  assert_dir_exists "$APP/web/sites/default/files/private/tmp"

  # Bootstrap.
  assert_equal "core:status" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 2)"

  # Database backup.
  assert_output_not_contains "Making a database backup."

  assert_output_contains "Drupal is not installed or not operational."

  # Common deploy.
  assert_output_not_contains "Performing content import."

  assert_output_not_contains "Performing config import."
  assert_output_not_contains "Performing development config import on non-production site."
  assert_output_not_contains "Enable stage_file_proxy in non-prod environments."

  assert_output_contains "Finished running govcms-deploy."
}

################################################################################
#                               PRODUCTION                                     #
################################################################################

@test "Production, no config" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 2
  mock_set_side_effect "${mock_drush}" "mkdir -p $APP/web/sites/default/files/private/backups && touch $APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" 3

  # Remove any values set in the current environment.
  export LAGOON_ENVIRONMENT_TYPE=production
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=
  export APP

  assert_dir_not_exists "$APP/web/sites/default/files/private/tmp"

  run "$CUR_DIR"/scripts/govcms-deploy
  assert_success

  assert_output_contains "Running govcms-deploy"
  assert_output_contains "Environment type: production"
  assert_output_contains "Config strategy:  import"
  assert_output_contains "Content strategy: retain"
  assert_output_contains "There are 0 config yaml files, and 0 dev yaml files."

  assert_dir_exists "$APP/web/sites/default/files/private/tmp"

  # Bootstrap.
  assert_equal "core:status" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 2)"

  # Database backup.
  assert_output_contains "Making a database backup."
  assert_dir_exists "$APP/web/sites/default/files/private/backups"
  assert_equal "sql:dump --gzip --result-file=$APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" "$(mock_get_call_args "${mock_drush}" 3)"

  # Common deploy.
  assert_output_not_contains "Performing content import."

  assert_equal "updatedb -y" "$(mock_get_call_args "${mock_drush}" 4)"
  assert_equal "cache:rebuild" "$(mock_get_call_args "${mock_drush}" 5)"

  assert_output_not_contains "Performing config import."
  assert_output_not_contains "Performing development config import on non-production site."
  assert_output_not_contains "Enable stage_file_proxy in non-prod environments."

  assert_output_contains "Finished running govcms-deploy."
}

@test "Production, default and dev config" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 2
  mock_set_side_effect "${mock_drush}" "mkdir -p $APP/web/sites/default/files/private/backups && touch $APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" 3

  # Remove any values set in the current environment.
  export LAGOON_ENVIRONMENT_TYPE=production
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=
  export APP

  fixture_config "$APP/config/default" 3
  fixture_config "$APP/config/dev" 2

  assert_dir_not_exists "$APP/web/sites/default/files/private/tmp"

  run "$CUR_DIR"/scripts/govcms-deploy
  assert_success

  assert_output_contains "Running govcms-deploy"
  assert_output_contains "Environment type: production"
  assert_output_contains "Config strategy:  import"
  assert_output_contains "Content strategy: retain"
  assert_output_contains "There are 3 config yaml files, and 2 dev yaml files."

  assert_dir_exists "$APP/web/sites/default/files/private/tmp"

  # Bootstrap.
  assert_equal "core:status" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 2)"

  # Database backup.
  assert_output_contains "Making a database backup."
  assert_dir_exists "$APP/web/sites/default/files/private/backups"
  assert_equal "sql:dump --gzip --result-file=$APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" "$(mock_get_call_args "${mock_drush}" 3)"

  # Common deploy.
  assert_output_not_contains "Performing content import."

  assert_equal "updatedb -y" "$(mock_get_call_args "${mock_drush}" 4)"
  assert_equal "cache:rebuild" "$(mock_get_call_args "${mock_drush}" 5)"

  assert_output_contains "Performing config import."
  assert_equal "config:import -y sync" "$(mock_get_call_args "${mock_drush}" 6)"
  assert_output_not_contains "Performing development config import on non-production site."
  assert_output_not_contains "Enable stage_file_proxy in non-prod environments."

  assert_output_contains "Finished running govcms-deploy."
}

@test "Production, no config, retain config" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 2
  mock_set_side_effect "${mock_drush}" "mkdir -p $APP/web/sites/default/files/private/backups && touch $APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" 3

  # Remove any values set in the current environment.
  export LAGOON_ENVIRONMENT_TYPE=production
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=retain
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=
  export APP

  assert_dir_not_exists "$APP/web/sites/default/files/private/tmp"

  run "$CUR_DIR"/scripts/govcms-deploy
  assert_success

  assert_output_contains "Running govcms-deploy"
  assert_output_contains "Environment type: production"
  assert_output_contains "Config strategy:  retain"
  assert_output_contains "Content strategy: retain"
  assert_output_contains "There are 0 config yaml files, and 0 dev yaml files."

  assert_dir_exists "$APP/web/sites/default/files/private/tmp"

  # Bootstrap.
  assert_equal "core:status" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 2)"

  # Database backup.
  assert_output_contains "Making a database backup."
  assert_dir_exists "$APP/web/sites/default/files/private/backups"
  assert_equal "sql:dump --gzip --result-file=$APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" "$(mock_get_call_args "${mock_drush}" 3)"

  # Common deploy.
  assert_output_not_contains "Performing content import."

  assert_equal "updatedb -y" "$(mock_get_call_args "${mock_drush}" 4)"
  assert_equal "cache:rebuild" "$(mock_get_call_args "${mock_drush}" 5)"

  assert_output_not_contains "Performing config import."
  assert_output_not_contains "Performing development config import on non-production site."
  assert_output_not_contains "Enable stage_file_proxy in non-prod environments."

  assert_output_contains "Finished running govcms-deploy."
}

@test "Production, default and dev config, retain config" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 2
  mock_set_side_effect "${mock_drush}" "mkdir -p $APP/web/sites/default/files/private/backups && touch $APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" 3

  # Remove any values set in the current environment.
  export LAGOON_ENVIRONMENT_TYPE=production
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=retain
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=
  export APP

  fixture_config "$APP/config/default" 3
  fixture_config "$APP/config/dev" 2

  assert_dir_not_exists "$APP/web/sites/default/files/private/tmp"

  run "$CUR_DIR"/scripts/govcms-deploy
  assert_success

  assert_output_contains "Running govcms-deploy"
  assert_output_contains "Environment type: production"
  assert_output_contains "Config strategy:  retain"
  assert_output_contains "Content strategy: retain"
  assert_output_contains "There are 3 config yaml files, and 2 dev yaml files."

  assert_dir_exists "$APP/web/sites/default/files/private/tmp"

  # Bootstrap.
  assert_equal "core:status" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 2)"

  # Database backup.
  assert_output_contains "Making a database backup."
  assert_dir_exists "$APP/web/sites/default/files/private/backups"
  assert_equal "sql:dump --gzip --result-file=$APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" "$(mock_get_call_args "${mock_drush}" 3)"

  # Common deploy.
  assert_output_not_contains "Performing content import."

  assert_equal "updatedb -y" "$(mock_get_call_args "${mock_drush}" 4)"
  assert_equal "cache:rebuild" "$(mock_get_call_args "${mock_drush}" 5)"

  assert_output_not_contains "Performing config import."
  assert_output_not_contains "Performing development config import on non-production site."
  assert_output_not_contains "Enable stage_file_proxy in non-prod environments."

  assert_output_contains "Finished running govcms-deploy."
}

@test "Production, default and dev config, import content" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 2
  mock_set_side_effect "${mock_drush}" "mkdir -p $APP/web/sites/default/files/private/backups && touch $APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" 3

  # Remove any values set in the current environment.
  export LAGOON_ENVIRONMENT_TYPE=production
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=import
  export APP

  fixture_config "$APP/config/default" 3
  fixture_config "$APP/config/dev" 2

  assert_dir_not_exists "$APP/web/sites/default/files/private/tmp"

  run "$CUR_DIR"/scripts/govcms-deploy
  assert_success

  assert_output_contains "Running govcms-deploy"
  assert_output_contains "Environment type: production"
  assert_output_contains "Config strategy:  import"
  assert_output_contains "Content strategy: import"
  assert_output_contains "There are 3 config yaml files, and 2 dev yaml files."

  assert_dir_exists "$APP/web/sites/default/files/private/tmp"

  # Bootstrap.
  assert_equal "core:status" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 2)"

  # Database backup.
  assert_output_contains "Making a database backup."
  assert_dir_exists "$APP/web/sites/default/files/private/backups"
  assert_equal "sql:dump --gzip --result-file=$APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" "$(mock_get_call_args "${mock_drush}" 3)"

  # Common deploy.
  assert_output_not_contains "Performing content import."

  assert_equal "updatedb -y" "$(mock_get_call_args "${mock_drush}" 4)"
  assert_equal "cache:rebuild" "$(mock_get_call_args "${mock_drush}" 5)"

  assert_output_contains "Performing config import."
  assert_equal "config:import -y sync" "$(mock_get_call_args "${mock_drush}" 6)"
  assert_output_not_contains "Performing development config import on non-production site."
  assert_output_not_contains "Enable stage_file_proxy in non-prod environments."

  assert_output_contains "Finished running govcms-deploy."
}

@test "Production, no config, not installed" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Failed" 2
  mock_set_side_effect "${mock_drush}" "mkdir -p $APP/web/sites/default/files/private/backups && touch $APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" 3

  # Remove any values set in the current environment.
  export LAGOON_ENVIRONMENT_TYPE=production
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=
  export APP

  assert_dir_not_exists "$APP/web/sites/default/files/private/tmp"

  run "$CUR_DIR"/scripts/govcms-deploy
  assert_success

  assert_output_contains "Running govcms-deploy"
  assert_output_contains "Environment type: production"
  assert_output_contains "Config strategy:  import"
  assert_output_contains "Content strategy: retain"
  assert_output_contains "There are 0 config yaml files, and 0 dev yaml files."

  assert_dir_exists "$APP/web/sites/default/files/private/tmp"

  # Bootstrap.
  assert_equal "core:status" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 2)"

  # Database backup.
  assert_output_not_contains "Making a database backup."

  assert_output_contains "Drupal is not installed or not operational."

  # Common deploy.
  assert_output_not_contains "Performing content import."

  assert_output_not_contains "Performing config import."
  assert_output_not_contains "Performing development config import on non-production site."
  assert_output_not_contains "Enable stage_file_proxy in non-prod environments."

  assert_output_contains "Finished running govcms-deploy."
}

################################################################################
#                               DEVELOPMENT                                    #
################################################################################

@test "Development, no config" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 2

  # Remove any values set in the current environment.
  export LAGOON_ENVIRONMENT_TYPE=development
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=
  export APP

  assert_dir_not_exists "$APP/web/sites/default/files/private/tmp"

  run "$CUR_DIR"/scripts/govcms-deploy
  assert_success

  assert_output_contains "Running govcms-deploy"
  assert_output_contains "Environment type: development"
  assert_output_contains "Config strategy:  import"
  assert_output_contains "Content strategy: retain"
  assert_output_contains "There are 0 config yaml files, and 0 dev yaml files."

  assert_dir_exists "$APP/web/sites/default/files/private/tmp"

  # Bootstrap.
  assert_equal "core:status" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 2)"

  # Database backup.
  assert_output_not_contains "Making a database backup."

  # Common deploy.
  assert_output_not_contains "Performing content import."

  assert_equal "updatedb -y" "$(mock_get_call_args "${mock_drush}" 3)"
  assert_equal "cache:rebuild" "$(mock_get_call_args "${mock_drush}" 4)"

  assert_output_not_contains "Performing config import."
  assert_output_not_contains "Performing development config import on non-production site."

  assert_output_contains "Enable stage_file_proxy in non-prod environments."
  assert_equal "pm:enable stage_file_proxy -y" "$(mock_get_call_args "${mock_drush}" 5)"

  assert_output_contains "Finished running govcms-deploy."
}

@test "Development, default and dev config" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 2
  mock_set_side_effect "${mock_drush}" "mkdir -p $APP/web/sites/default/files/private/backups && touch $APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" 3

  # Remove any values set in the current environment.
  export LAGOON_ENVIRONMENT_TYPE=development
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=
  export APP

  fixture_config "$APP/config/default" 3
  fixture_config "$APP/config/dev" 2

  assert_dir_not_exists "$APP/web/sites/default/files/private/tmp"

  run "$CUR_DIR"/scripts/govcms-deploy
  assert_success

  assert_output_contains "Running govcms-deploy"
  assert_output_contains "Environment type: development"
  assert_output_contains "Config strategy:  import"
  assert_output_contains "Content strategy: retain"
  assert_output_contains "There are 3 config yaml files, and 2 dev yaml files."

  assert_dir_exists "$APP/web/sites/default/files/private/tmp"

  # Bootstrap.
  assert_equal "core:status" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 2)"

  # Database backup.
  assert_output_not_contains "Making a database backup."

  # Common deploy.
  assert_output_not_contains "Performing content import."

  assert_equal "updatedb -y" "$(mock_get_call_args "${mock_drush}" 3)"
  assert_equal "cache:rebuild" "$(mock_get_call_args "${mock_drush}" 4)"

  assert_output_contains "Performing config import."
  assert_equal "config:import -y sync" "$(mock_get_call_args "${mock_drush}" 5)"
  assert_output_contains "Performing development config import on non-production site."
  assert_equal "config:import -y --partial --source=../config/dev" "$(mock_get_call_args "${mock_drush}" 6)"

  assert_output_contains "Enable stage_file_proxy in non-prod environments."
  assert_equal "pm:enable stage_file_proxy -y" "$(mock_get_call_args "${mock_drush}" 7)"

  assert_output_contains "Finished running govcms-deploy."
}

@test "Development, no config, retain config" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 2
  mock_set_side_effect "${mock_drush}" "mkdir -p $APP/web/sites/default/files/private/backups && touch $APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" 3

  # Remove any values set in the current environment.
  export LAGOON_ENVIRONMENT_TYPE=development
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=retain
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=
  export APP

  assert_dir_not_exists "$APP/web/sites/default/files/private/tmp"

  run "$CUR_DIR"/scripts/govcms-deploy
  assert_success

  assert_output_contains "Running govcms-deploy"
  assert_output_contains "Environment type: development"
  assert_output_contains "Config strategy:  retain"
  assert_output_contains "Content strategy: retain"
  assert_output_contains "There are 0 config yaml files, and 0 dev yaml files."

  assert_dir_exists "$APP/web/sites/default/files/private/tmp"

  # Bootstrap.
  assert_equal "core:status" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 2)"

  # Database backup.
  assert_output_not_contains "Making a database backup."

  # Common deploy.
  assert_output_not_contains "Performing content import."

  assert_equal "updatedb -y" "$(mock_get_call_args "${mock_drush}" 3)"
  assert_equal "cache:rebuild" "$(mock_get_call_args "${mock_drush}" 4)"

  assert_output_not_contains "Performing config import."
  assert_output_not_contains "Performing development config import on non-production site."

  assert_output_contains "Enable stage_file_proxy in non-prod environments."
  assert_equal "pm:enable stage_file_proxy -y" "$(mock_get_call_args "${mock_drush}" 5)"

  assert_output_contains "Finished running govcms-deploy."
}

@test "Development, default and dev config, retain config" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 2
  mock_set_side_effect "${mock_drush}" "mkdir -p $APP/web/sites/default/files/private/backups && touch $APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" 3

  # Remove any values set in the current environment.
  export LAGOON_ENVIRONMENT_TYPE=development
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=retain
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=
  export APP

  fixture_config "$APP/config/default" 3
  fixture_config "$APP/config/dev" 2

  assert_dir_not_exists "$APP/web/sites/default/files/private/tmp"

  run "$CUR_DIR"/scripts/govcms-deploy
  assert_success

  assert_output_contains "Running govcms-deploy"
  assert_output_contains "Environment type: development"
  assert_output_contains "Config strategy:  retain"
  assert_output_contains "Content strategy: retain"
  assert_output_contains "There are 3 config yaml files, and 2 dev yaml files."

  assert_dir_exists "$APP/web/sites/default/files/private/tmp"

  # Bootstrap.
  assert_equal "core:status" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 2)"

  # Database backup.
  assert_output_not_contains "Making a database backup."

  # Common deploy.
  assert_output_not_contains "Performing content import."

  assert_equal "updatedb -y" "$(mock_get_call_args "${mock_drush}" 3)"
  assert_equal "cache:rebuild" "$(mock_get_call_args "${mock_drush}" 4)"

  assert_output_not_contains "Performing config import."
  assert_output_not_contains "Performing development config import on non-production site."

  assert_output_contains "Enable stage_file_proxy in non-prod environments."
  assert_equal "pm:enable stage_file_proxy -y" "$(mock_get_call_args "${mock_drush}" 5)"

  assert_output_contains "Finished running govcms-deploy."
}

@test "Development, default and dev config, import content" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 2
  mock_set_side_effect "${mock_drush}" "mkdir -p $APP/web/sites/default/files/private/backups && touch $APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" 3

  # Remove any values set in the current environment.
  export LAGOON_ENVIRONMENT_TYPE=development
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=import
  export APP

  fixture_config "$APP/config/default" 3
  fixture_config "$APP/config/dev" 2

  assert_dir_not_exists "$APP/web/sites/default/files/private/tmp"

  run "$CUR_DIR"/scripts/govcms-deploy
  assert_success

  assert_output_contains "Running govcms-deploy"
  assert_output_contains "Environment type: development"
  assert_output_contains "Config strategy:  import"
  assert_output_contains "Content strategy: import"
  assert_output_contains "There are 3 config yaml files, and 2 dev yaml files."

  assert_dir_exists "$APP/web/sites/default/files/private/tmp"

  # Bootstrap.
  assert_equal "core:status" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 2)"

  # Database backup.
  assert_output_not_contains "Making a database backup."

  # Common deploy.
  assert_output_contains "Performing content import."
  assert_equal "--alias-path=/etc/drush/sites sql:sync @ci.prod @self -y" "$(mock_get_call_args "${mock_drush}" 3)"

  assert_equal "updatedb -y" "$(mock_get_call_args "${mock_drush}" 4)"
  assert_equal "cache:rebuild" "$(mock_get_call_args "${mock_drush}" 5)"

  assert_output_contains "Performing config import."
  assert_equal "config:import -y sync" "$(mock_get_call_args "${mock_drush}" 6)"
  assert_output_contains "Performing development config import on non-production site."
  assert_equal "config:import -y --partial --source=../config/dev" "$(mock_get_call_args "${mock_drush}" 7)"

  assert_output_contains "Enable stage_file_proxy in non-prod environments."
  assert_equal "pm:enable stage_file_proxy -y" "$(mock_get_call_args "${mock_drush}" 8)"

  assert_output_contains "Finished running govcms-deploy."
}

@test "Development, no config, not installed" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Failed" 2
  mock_set_side_effect "${mock_drush}" "mkdir -p $APP/web/sites/default/files/private/backups && touch $APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" 3

  # Remove any values set in the current environment.
  export LAGOON_ENVIRONMENT_TYPE=development
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=
  export APP

  assert_dir_not_exists "$APP/web/sites/default/files/private/tmp"

  run "$CUR_DIR"/scripts/govcms-deploy
  assert_success

  assert_output_contains "Running govcms-deploy"
  assert_output_contains "Environment type: development"
  assert_output_contains "Config strategy:  import"
  assert_output_contains "Content strategy: retain"
  assert_output_contains "There are 0 config yaml files, and 0 dev yaml files."

  assert_dir_exists "$APP/web/sites/default/files/private/tmp"

  # Bootstrap.
  assert_equal "core:status" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 2)"

  # Database backup.
  assert_output_not_contains "Making a database backup."

  assert_output_contains "Drupal is not installed or not operational."
  assert_equal "--alias-path=/etc/drush/sites sql:sync @ci.prod @self -y" "$(mock_get_call_args "${mock_drush}" 3)"

  # Common deploy.
  assert_output_not_contains "Performing content import."

  assert_equal "updatedb -y" "$(mock_get_call_args "${mock_drush}" 4)"
  assert_equal "cache:rebuild" "$(mock_get_call_args "${mock_drush}" 5)"

  assert_output_not_contains "Performing config import."
  assert_output_not_contains "Performing development config import on non-production site."

  assert_output_contains "Enable stage_file_proxy in non-prod environments."
  assert_equal "pm:enable stage_file_proxy -y" "$(mock_get_call_args "${mock_drush}" 6)"

  assert_output_contains "Finished running govcms-deploy."
}

################################################################################
#                                  LOCAL                                       #
################################################################################

@test "Local, no config" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 2

  # Remove any values set in the current environment.
  export LAGOON_ENVIRONMENT_TYPE=local
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=
  export APP

  assert_dir_not_exists "$APP/web/sites/default/files/private/tmp"

  run "$CUR_DIR"/scripts/govcms-deploy
  assert_success

  assert_output_contains "Running govcms-deploy"
  assert_output_contains "Environment type: local"
  assert_output_contains "Config strategy:  import"
  assert_output_contains "Content strategy: retain"
  assert_output_contains "There are 0 config yaml files, and 0 dev yaml files."

  assert_dir_exists "$APP/web/sites/default/files/private/tmp"

  # Bootstrap.
  assert_equal "core:status" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 2)"

  # Database backup.
  assert_output_not_contains "Making a database backup."

  # Common deploy.
  assert_output_not_contains "Performing content import."

  assert_equal "updatedb -y" "$(mock_get_call_args "${mock_drush}" 3)"
  assert_equal "cache:rebuild" "$(mock_get_call_args "${mock_drush}" 4)"

  assert_output_not_contains "Performing config import."
  assert_output_not_contains "Performing development config import on non-production site."

  assert_output_contains "Enable stage_file_proxy in non-prod environments."
  assert_equal "pm:enable stage_file_proxy -y" "$(mock_get_call_args "${mock_drush}" 5)"

  assert_output_contains "Finished running govcms-deploy."
}

@test "Local, default and dev config" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 2
  mock_set_side_effect "${mock_drush}" "mkdir -p $APP/web/sites/default/files/private/backups && touch $APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" 3

  # Remove any values set in the current environment.
  export LAGOON_ENVIRONMENT_TYPE=local
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=
  export APP

  fixture_config "$APP/config/default" 3
  fixture_config "$APP/config/dev" 2

  assert_dir_not_exists "$APP/web/sites/default/files/private/tmp"

  run "$CUR_DIR"/scripts/govcms-deploy
  assert_success

  assert_output_contains "Running govcms-deploy"
  assert_output_contains "Environment type: local"
  assert_output_contains "Config strategy:  import"
  assert_output_contains "Content strategy: retain"
  assert_output_contains "There are 3 config yaml files, and 2 dev yaml files."

  assert_dir_exists "$APP/web/sites/default/files/private/tmp"

  # Bootstrap.
  assert_equal "core:status" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 2)"

  # Database backup.
  assert_output_not_contains "Making a database backup."

  # Common deploy.
  assert_output_not_contains "Performing content import."

  assert_equal "updatedb -y" "$(mock_get_call_args "${mock_drush}" 3)"
  assert_equal "cache:rebuild" "$(mock_get_call_args "${mock_drush}" 4)"

  assert_output_contains "Performing config import."
  assert_equal "config:import -y sync" "$(mock_get_call_args "${mock_drush}" 5)"
  assert_output_contains "Performing development config import on non-production site."
  assert_equal "config:import -y --partial --source=../config/dev" "$(mock_get_call_args "${mock_drush}" 6)"

  assert_output_contains "Enable stage_file_proxy in non-prod environments."
  assert_equal "pm:enable stage_file_proxy -y" "$(mock_get_call_args "${mock_drush}" 7)"

  assert_output_contains "Finished running govcms-deploy."
}

@test "Local, no config, retain config" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 2
  mock_set_side_effect "${mock_drush}" "mkdir -p $APP/web/sites/default/files/private/backups && touch $APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" 3

  # Remove any values set in the current environment.
  export LAGOON_ENVIRONMENT_TYPE=local
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=retain
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=
  export APP

  assert_dir_not_exists "$APP/web/sites/default/files/private/tmp"

  run "$CUR_DIR"/scripts/govcms-deploy
  assert_success

  assert_output_contains "Running govcms-deploy"
  assert_output_contains "Environment type: local"
  assert_output_contains "Config strategy:  retain"
  assert_output_contains "Content strategy: retain"
  assert_output_contains "There are 0 config yaml files, and 0 dev yaml files."

  assert_dir_exists "$APP/web/sites/default/files/private/tmp"

  # Bootstrap.
  assert_equal "core:status" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 2)"

  # Database backup.
  assert_output_not_contains "Making a database backup."

  # Common deploy.
  assert_output_not_contains "Performing content import."

  assert_equal "updatedb -y" "$(mock_get_call_args "${mock_drush}" 3)"
  assert_equal "cache:rebuild" "$(mock_get_call_args "${mock_drush}" 4)"

  assert_output_not_contains "Performing config import."
  assert_output_not_contains "Performing development config import on non-production site."

  assert_output_contains "Enable stage_file_proxy in non-prod environments."
  assert_equal "pm:enable stage_file_proxy -y" "$(mock_get_call_args "${mock_drush}" 5)"

  assert_output_contains "Finished running govcms-deploy."
}

@test "Local, default and dev config, retain config" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 2
  mock_set_side_effect "${mock_drush}" "mkdir -p $APP/web/sites/default/files/private/backups && touch $APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" 3

  # Remove any values set in the current environment.
  export LAGOON_ENVIRONMENT_TYPE=local
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=retain
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=
  export APP

  fixture_config "$APP/config/default" 3
  fixture_config "$APP/config/dev" 2

  assert_dir_not_exists "$APP/web/sites/default/files/private/tmp"

  run "$CUR_DIR"/scripts/govcms-deploy
  assert_success

  assert_output_contains "Running govcms-deploy"
  assert_output_contains "Environment type: local"
  assert_output_contains "Config strategy:  retain"
  assert_output_contains "Content strategy: retain"
  assert_output_contains "There are 3 config yaml files, and 2 dev yaml files."

  assert_dir_exists "$APP/web/sites/default/files/private/tmp"

  # Bootstrap.
  assert_equal "core:status" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 2)"

  # Database backup.
  assert_output_not_contains "Making a database backup."

  # Common deploy.
  assert_output_not_contains "Performing content import."

  assert_equal "updatedb -y" "$(mock_get_call_args "${mock_drush}" 3)"
  assert_equal "cache:rebuild" "$(mock_get_call_args "${mock_drush}" 4)"

  assert_output_not_contains "Performing config import."
  assert_output_not_contains "Performing development config import on non-production site."

  assert_output_contains "Enable stage_file_proxy in non-prod environments."
  assert_equal "pm:enable stage_file_proxy -y" "$(mock_get_call_args "${mock_drush}" 5)"

  assert_output_contains "Finished running govcms-deploy."
}

@test "Local, default and dev config, import content" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 2
  mock_set_side_effect "${mock_drush}" "mkdir -p $APP/web/sites/default/files/private/backups && touch $APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" 3

  # Remove any values set in the current environment.
  export LAGOON_ENVIRONMENT_TYPE=local
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=import
  export APP

  fixture_config "$APP/config/default" 3
  fixture_config "$APP/config/dev" 2

  assert_dir_not_exists "$APP/web/sites/default/files/private/tmp"

  run "$CUR_DIR"/scripts/govcms-deploy
  assert_success

  assert_output_contains "Running govcms-deploy"
  assert_output_contains "Environment type: local"
  assert_output_contains "Config strategy:  import"
  assert_output_contains "Content strategy: import"
  assert_output_contains "There are 3 config yaml files, and 2 dev yaml files."

  assert_dir_exists "$APP/web/sites/default/files/private/tmp"

  # Bootstrap.
  assert_equal "core:status" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 2)"

  # Database backup.
  assert_output_not_contains "Making a database backup."

  # Common deploy.
  assert_output_not_contains "Performing content import."

  assert_equal "updatedb -y" "$(mock_get_call_args "${mock_drush}" 3)"
  assert_equal "cache:rebuild" "$(mock_get_call_args "${mock_drush}" 4)"

  assert_output_contains "Performing config import."
  assert_equal "config:import -y sync" "$(mock_get_call_args "${mock_drush}" 5)"
  assert_output_contains "Performing development config import on non-production site."
  assert_equal "config:import -y --partial --source=../config/dev" "$(mock_get_call_args "${mock_drush}" 6)"

  assert_output_contains "Enable stage_file_proxy in non-prod environments."
  assert_equal "pm:enable stage_file_proxy -y" "$(mock_get_call_args "${mock_drush}" 7)"

  assert_output_contains "Finished running govcms-deploy."
}

@test "Local, no config, not installed" {
  APP="$TEST_APP_DIR"
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Failed" 2
  mock_set_side_effect "${mock_drush}" "mkdir -p $APP/web/sites/default/files/private/backups && touch $APP/web/sites/default/files/private/backups/pre-deploy-dump.sql" 3

  # Remove any values set in the current environment.
  export LAGOON_ENVIRONMENT_TYPE=local
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=
  export GOVCMS_DEPLOY_WORKFLOW_CONTENT=
  export APP

  assert_dir_not_exists "$APP/web/sites/default/files/private/tmp"

  run "$CUR_DIR"/scripts/govcms-deploy
  assert_success

  assert_output_contains "Running govcms-deploy"
  assert_output_contains "Environment type: local"
  assert_output_contains "Config strategy:  import"
  assert_output_contains "Content strategy: retain"
  assert_output_contains "There are 0 config yaml files, and 0 dev yaml files."

  assert_dir_exists "$APP/web/sites/default/files/private/tmp"

  # Bootstrap.
  assert_equal "core:status" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_equal "status --fields=bootstrap" "$(mock_get_call_args "${mock_drush}" 2)"

  # Database backup.
  assert_output_not_contains "Making a database backup."

  assert_output_contains "Drupal is not installed or not operational."
  assert_output_contains  "Drupal is not installed locally, try ahoy install"

  # Common deploy.
  assert_output_not_contains "Performing content import."

  assert_output_not_contains "Performing config import."
  assert_output_not_contains "Performing development config import on non-production site."
  assert_output_not_contains "Enable stage_file_proxy in non-prod environments."

  assert_output_contains "Finished running govcms-deploy."
}
