#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030,SC2155

load ../_helpers_govcms

@test "Validate theme yaml: defaults" {
  run scripts/validate/govcms-validate-platform-yml >&3
  assert_output_contains "GovCMS Validate :: Yaml lint platform files"
}

@test "Validate theme yaml: valid yaml" {
  export GOVCMS_PLATFORM_FILES=$(find tests/bats/validate/fixtures -type f \( -name "yaml-valid.yml" \) -print0)
  export GOVCMS_YAML_LINT=govcms-yaml_lint

  mock_yaml_lint=$(mock_command govcms-yaml_lint)
  mock_set_output "${mock_yaml_lint}" "No lint errors found" 1

  run scripts/validate/govcms-validate-platform-yml >&3

  assert_output_contains "GovCMS Validate :: Yaml lint platform files"
  assert_output_contains "[success]: No YAML issues in platform files."
}

@test "Validate theme yaml: invalid yaml" {
  export GOVCMS_PLATFORM_FILES=$(find tests/bats/validate/fixtures -type f \( -name "yaml-invalid.yml" \) -print0)
  export GOVCMS_YAML_LINT=govcms-yaml_lint

  mock_yaml_lint=$(mock_command govcms-yaml_lint)
  mock_set_output "${mock_yaml_lint}" "Errors found" 1
  mock_set_status "${mock_yaml_lint}" 1 1

  run scripts/validate/govcms-validate-platform-yml >&3

  assert_output_contains "GovCMS Validate :: Yaml lint platform files"
  assert_output_contains "[fail]: $GOVCMS_PLATFORM_FILES failed lint"
}
