#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030

load ../_helpers_govcms

@test "Active modules: defaults" {
  run scripts/validate/govcms-validate-active-modules >&3
  assert_output_contains "GovCMS Validate :: Active modules validation"
}

# Module status could not be determined, we treat this is a failure case.
@test "Active modules: Invaild drush output" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "{  }" 1

  run scripts/validate/govcms-validate-active-modules >&3

  assert_output_contains "GovCMS Validate :: Active modules validation"
  assert_output_contains "[fail]: 'tfa' is not enabled"
  assert_output_contains "[fail]: 'govcms_security' is not enabled"

  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"

  assert_failure
}

@test "Acitve modules: missing required" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{ "tfa": { "status": "enabled" }  }' 1

  run scripts/validate/govcms-validate-active-modules >&3

  assert_output_contains "GovCMS Validate :: Active modules validation"
  assert_output_contains "[fail]: 'govcms_security' is not enabled"

  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"

  assert_failure
}

@test "Active modules: disallowed enabled" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{ "tfa": { "status": "enabled"}, "govcms_security": {"status": "enabled"}, "update": {"status": "enabled"} }' 1

  run scripts/validate/govcms-validate-active-modules >&3

  assert_output_contains "GovCMS Validate :: Active modules validation"
  assert_output_contains "[fail]: 'update' is enabled"

  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"

  assert_failure
}

@test "Active modules: missing required and enabled disallowed" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{ "tfa": { "status": "enabled"}, "update": {"status": "enabled"} }' 1

  run scripts/validate/govcms-validate-active-modules >&3

  assert_output_contains "GovCMS Validate :: Active modules validation"
  assert_output_contains "[fail]: 'govcms_security' is not enabled"
  assert_output_contains "[fail]: 'update' is enabled"

  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"

  assert_failure
}

@test "Active modules: remediate (missing, disallowed)" {
  export GOVCMS_REMEDIATE=1

  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{ "tfa": { "status": "enabled"}, "update": {"status": "enabled"} }' 1

  run scripts/validate/govcms-validate-active-modules >&3

  assert_output_contains "GovCMS Validate :: Active modules validation"

  assert_equal 3 "$(mock_get_call_num "${mock_drush}")"
  assert_equal "pm:enable govcms_security -y" "$(mock_get_call_args "${mock_drush}" 2)"
  assert_equal "pm:disable update -y" "$(mock_get_call_args "${mock_drush}" 3)"

  assert_success

  unset GOVCMS_REMEDIATE
}

@test "Active modules: okay" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{ "tfa": { "status": "enabled"}, "govcms_security": {"status": "enabled"} }' 1

  run scripts/validate/govcms-validate-active-modules >&3

  assert_output_contains "GovCMS Validate :: Active modules validation"

  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"

  assert_success
}
