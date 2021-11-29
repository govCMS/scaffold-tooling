#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030,SC2034,SC2155

load _helpers_govcms

@test "Run drush command" {
  mock_drush=$(mock_command drush)
  run scripts/govcms-drush cron
  assert_success
  assert_output_contains "GovCMS Drush"
}

@test "Drush command with options" {
  mock_drush=$(mock_command drush)
  run scripts/govcms-drush cron --root=/app
  assert_success
  assert_equal "cron --root=/app" "$(mock_get_call_args "${mock_drush}" 1)"
}

@test "Drush command failure" {
  mock_drush=$(mock_command drush)
  mock_set_status "$mock_drush" 1

  run scripts/govcms-drush cron
  assert_failure
  assert_output_contains "GovCMS Drush"
  assert_equal "cron" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_output_contains "[fail]: Command failed, notifications not enabled. Skipping."
}

@test "Drush command failure send emails" {
  mock_drush=$(mock_command drush)
  mock_set_output "$mock_drush" "Error found"
  mock_set_status "$mock_drush" 1

  mock_sendmail=$(mock_command sendmail)
  mock_set_status "$mock_sendmail" 0

  export GOVCMS_DRUSH_NOTIFICATION_ENABLE=true
  export LAGOON_PROJECT=test
  export LAGOON_GIT_BRANCH=test

  run scripts/govcms-drush cron
  assert_failure
  assert_output_contains "GovCMS Drush"
  assert_equal "cron" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_output_contains "[fail]: Command failed sending notifications."
  assert_equal "govcms.devops@salsadigital.com.au" "$(mock_get_call_args "${mock_sendmail}" 1)"
}

@test "Drush command recipients" {
  mock_drush=$(mock_command drush)
  mock_set_output "$mock_drush" "Error found"
  mock_set_status "$mock_drush" 1

  mock_sendmail=$(mock_command sendmail)
  mock_set_status "$mock_sendmail" 0

  export GOVCMS_DRUSH_NOTIFICATION_ENABLE=true
  export LAGOON_PROJECT=test
  export LAGOON_GIT_BRANCH=test
  export GOVCMS_DRUSH_RECIPIENTS="test@test.com,test2@test.com"

  run scripts/govcms-drush cron
  assert_failure
  assert_output_contains "GovCMS Drush"
  assert_equal "cron" "$(mock_get_call_args "${mock_drush}" 1)"
  assert_output_contains "[fail]: Command failed sending notifications."
  assert_equal "govcms.devops@salsadigital.com.au,test@testm.com,test2@test.com" "$(mock_get_call_args "${mock_sendmail}" 1)"
}
