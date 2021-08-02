#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030,SC2155

load ../_helpers_govcms

@test "Check profile: defaults" {
  run scripts/validate/govcms-validate-profile >&3
  echo "GovCMS Validate :: Validate install profile"
  assert_failure
}

@test "Check profile: invalid" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "core.extension.invalid-profile.yml" \) -print0)

  run scripts/validate/govcms-validate-profile >&3

  assert_output_contains "GovCMS Validate :: Validate install profile"
  assert_output_contains "[fail]: Invalid profile detected standard"
  assert_failure
}

@test "Check profile: valid" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "core.extension.valid-profile.yml" \) -print0)

  run scripts/validate/govcms-validate-profile >&3

  assert_output_contains "GovCMS Validate :: Validate install profile"
  assert_output_contains "[success]: 'govcms' profile is in use"

  assert_success
}
