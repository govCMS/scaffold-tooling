#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030

load ../_helpers_govcms

@test "Check active TFA: defaults" {
  run scripts/validate/govcms-validate-active-tfa >&3
  assert_output_contains "GovCMS Validate :: Validate TFA config on active site"
  assert_failure
}

@test "Check active TFA: invalid" {
  DRUSH_OUTPUT=$(cat tests/bats/validate/fixtures/tfa-invalid.json)
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "${DRUSH_OUTPUT}" 1

  run scripts/validate/govcms-validate-active-tfa >&3

  assert_output_contains "GovCMS Validate :: Validate TFA config on active site"
  assert_output_contains "[fail]: TFA not enabled"
  assert_output_contains "[fail]: TFA is not required for authenticated users"
  assert_output_contains "[fail]: TFA is not actively enabled or enabled but not properly configured"

  assert_failure
}

@test "Check active TFA: valid" {
  DRUSH_OUTPUT=$(cat tests/bats/validate/fixtures/tfa-valid.json)
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "${DRUSH_OUTPUT}" 1

  run scripts/validate/govcms-validate-active-tfa >&3

  assert_output_contains "GovCMS Validate :: Validate TFA config on active site"
  assert_output_contains "[info]: TFA is enabled"
  assert_output_contains "[info]: TFA is required for authenticated users"
  assert_output_contains "[success]: TFA is actively enabled and properly configured"

  assert_success
}

@test "Check active TFA: enabled but not properly configured" {
  DRUSH_OUTPUT=$(cat tests/bats/validate/fixtures/tfa-valid-partial.json)
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "${DRUSH_OUTPUT}" 1

  run scripts/validate/govcms-validate-active-tfa >&3

  assert_output_contains "GovCMS Validate :: Validate TFA config"
  assert_output_contains "[info]: TFA is enabled"
  assert_output_contains "[fail]: TFA is not required for authenticated users"
  assert_output_contains "[fail]: TFA is not actively enabled or enabled but not properly configured"

  assert_failure
}
