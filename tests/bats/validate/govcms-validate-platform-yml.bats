#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030,SC2155

load ../_helpers_govcms

@test "Validate platform yaml: defaults" {
  run scripts/validate/govcms-validate-platform-yml >&3
  eassert_output_contains "GovCMS Validate :: Yaml lint platform files"
}

@test "Validate platform yaml: valid yaml" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "yaml-valid.yml" \) -print0)

  run scripts/validate/govcms-validate-platform-yml >&3

  eassert_output_contains "GovCMS Validate :: Yaml lint platform files"
  eassert_output_contains "[success]: No elevated permissions detected in configuration."
}

@test "Validate platform yaml: invalid yaml" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "yaml-invalid.yml" \) -print0)

  run scripts/validate/govcms-validate-platform-yml >&3

  eassert_output_contains "GovCMS Validate :: Yaml lint platform files"
  eassert_output_contains "[fail]: $GOVCMS_FILE_LIST has invalid YAML"
}
