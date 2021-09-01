#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030,SC2155

load ../_helpers_govcms

@test "Check prevent module: defaults" {
  run scripts/validate/govcms-validate-theme-modules >&3
  assert_output_contains "GovCMS Validate :: Scan themes for modules"
}

@test "Check prevent module: pass" {
  export GOVCMS_INFO_FILE_LIST=$(find tests/bats/validate/fixtures/theme -type f -name "*.info.yml")
  run scripts/validate/govcms-validate-theme-modules >&3
  assert_output_contains "GovCMS Validate :: Scan themes for modules"
  assert_output_contains "[success]: No modules detected."
}
@test "Check prevent module: module found" {
  export GOVCMS_INFO_FILE_LIST=$(find tests/bats/validate/fixtures/module -type f -name "*.info.yml")
  run scripts/validate/govcms-validate-theme-modules >&3
  assert_output_contains "GovCMS Validate :: Scan themes for modules"
  assert_output_contains "[fail]: Module detected with $GOVCMS_INFO_FILE_LIST"
}

@test "Check prevent module: skipped" {
  export GOVCMS_INFO_FILE_LIST=$(find tests/bats/validate/fixtures/theme -type f -name "*.info.yml")
  export GOVCMS_PREVENT_THEME_MODULES=false
  run scripts/validate/govcms-validate-theme-modules >&3
  assert_output_contains "GovCMS Validate :: Scan themes for modules"
  assert_output_contains "[skip]: Module detection is disabled."
}
