#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030

load ../_helpers_govcms

@test "Check profile: defaults" {
  run scripts/validate/govcms-validate-active-profile >&3
  assert_output_contains "GovCMS Validate :: Validate profile on active site"
}

@test "Check profile: invalid" {
  DRUSH_OUTPUT=$(cat tests/bats/validate/fixtures/profile-invalid.json)
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "${DRUSH_OUTPUT}" 1

  run scripts/validate/govcms-validate-active-profile >&3

  assert_output_contains "GovCMS Validate :: Validate profile on active site"
  assert_output_contains "[fail]: Detected invalid profile [standard]"
  assert_failure
}

@test "Check profile: valid" {
  DRUSH_OUTPUT=$(cat tests/bats/validate/fixtures/profile-valid.json)
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "${DRUSH_OUTPUT}" 1

  run scripts/validate/govcms-validate-active-profile >&3

  assert_output_contains "GovCMS Validate :: Validate profile on active site"
  assert_output_contains "[success]: 'govcms' profile is in use"
  assert_success
}
