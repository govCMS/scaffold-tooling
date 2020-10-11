#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030

load ../_helpers_govcms

@test "Update database: defaults" {
  mock_drush=$(mock_command "drush")

  run scripts/deploy/govcms-db-update >&3

  assert_output_contains "GovCMS Deploy :: Update Database"
  assert_output_contains "[info]: Preparing database update."

  assert_output_contains "[success]: Completed successfully."
  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"
}

@test "Update database: skip" {
  mock_drush=$(mock_command "drush")

  export GOVCMS_DEPLOY_UPDB=false
  run scripts/deploy/govcms-db-update >&3

  assert_output_contains "GovCMS Deploy :: Update Database"
  assert_output_contains "[skip]: Environment variable is set to skip."
  assert_output_not_contains "[info]: Preparing database update."

  assert_output_not_contains "[success]: Completed successfully."
  assert_equal 0 "$(mock_get_call_num "${mock_drush}")"
}

@test "Update database: pre-deploy tasks" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 2

  export GOVCMS_DEPLOY_PRE_UPDB=true
  run scripts/deploy/govcms-db-update >&3

  assert_output_contains "GovCMS Deploy :: Update Database"
  assert_output_contains "[skip]: Pre-deploy updates were applied."
  assert_output_not_contains "[info]: Preparing database update."

  assert_output_not_contains "[success]: Completed successfully."
  assert_equal 0 "$(mock_get_call_num "${mock_drush}")"
}

@test "Update database: no bootstrap" {
  mock_drush=$(mock_command "drush")

  run scripts/deploy/govcms-db-update >&3

  assert_output_contains "GovCMS Deploy :: Update Database"
  assert_output_contains "[skip]: Site is not available."
  assert_output_not_contains "[info]: Preparing database update."

  assert_output_not_contains "[success]: Completed successfully."
  assert_equal 0 "$(mock_get_call_num "${mock_drush}")"
}
