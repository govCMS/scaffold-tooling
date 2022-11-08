#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030,SC2155

load ../_helpers_govcms

@test "Check TFA: defaults" {
  run scripts/validate/govcms-validate-tfa >&3
  assert_output_contains "GovCMS Validate :: Validate TFA config"
  assert_failure
}

@test "Check TFA: invalid" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "tfa.settings.invalid.yml" \) -print0)

  run scripts/validate/govcms-validate-tfa >&3

  assert_output_contains "GovCMS Validate :: Validate TFA config"
  assert_output_contains "[fail]: TFA not enabled"
  assert_output_contains "[fail]: TFA is not required for authenticated users"
  assert_output_contains "[fail]: TFA is not enabled or not properly configured"

  assert_failure
}

@test "Check TFA: invalid 2" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "tfa.settings.invalid-2.yml" \) -print0)

  run scripts/validate/govcms-validate-tfa >&3

  assert_output_contains "GovCMS Validate :: Validate TFA config"
  assert_output_contains "[fail]: TFA not enabled"
  assert_output_contains "[fail]: TFA is not required for authenticated users"
  assert_output_contains "[fail]: TFA is not enabled or not properly configured"

  assert_failure
}

@test "Check TFA: valid" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "tfa.settings.valid.yml" \) -print0)

  run scripts/validate/govcms-validate-tfa >&3

  assert_output_contains "GovCMS Validate :: Validate TFA config"
  assert_output_contains "[info]: TFA is enabled"
  assert_output_contains "[info]: TFA is required for authenticated users"
  assert_output_contains "[success]: TFA is enabled and properly configured"

  assert_success
}

@test "Check TFA: valid 2" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "tfa.settings.valid-2.yml" \) -print0)

  run scripts/validate/govcms-validate-tfa >&3

  assert_output_contains "GovCMS Validate :: Validate TFA config"
  assert_output_contains "[info]: TFA is enabled"
  assert_output_contains "[info]: TFA is required for authenticated users"
  assert_output_contains "[success]: TFA is enabled and properly configured"

  assert_success
}


@test "Check TFA: enabled but not properly configured" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "tfa.settings.valid-partial.yml" \) -print0)

  run scripts/validate/govcms-validate-tfa >&3

  assert_output_contains "GovCMS Validate :: Validate TFA config"
  assert_output_contains "[info]: TFA is enabled"
  assert_output_contains "[fail]: TFA is not required for authenticated users"
  assert_output_contains "[fail]: TFA is not enabled or not properly configured"

  assert_failure
}
