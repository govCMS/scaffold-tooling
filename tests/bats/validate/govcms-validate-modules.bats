#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030,SC2155

load ../_helpers_govcms

@test "Validate modules: no config" {
  export GOVCMS_CONFIG_FOLDER_PATH="tests/bats/validate/fixtures/config"
  export GOVCMS_CORE_EXTENTION_FILE_NAME=""

  run scripts/validate/govcms-validate-modules >&3

  assert_output_contains "Coudn't find core.extension.yml file."
  assert_success
}

@test "Validate modules: missing required" {
  export GOVCMS_CONFIG_FOLDER_PATH="tests/bats/validate/fixtures/config"
  export GOVCMS_CORE_EXTENTION_FILE_NAME="core.extension-missing-required.yml"

  run scripts/validate/govcms-validate-modules >&3

  assert_output_contains "[fail]: Modules are in invalid states"
  assert_failure
}


@test "Validate modules: disallowed" {
  export GOVCMS_CONFIG_FOLDER_PATH="tests/bats/validate/fixtures/config"
  export GOVCMS_CORE_EXTENTION_FILE_NAME="core.extension-with-disallowed-modules.yml"

  run scripts/validate/govcms-validate-modules >&3

  assert_output_contains "[fail]: Modules are in invalid states"
  assert_failure
}

@test "Validate modules: okay!" {
  export GOVCMS_CONFIG_FOLDER_PATH="tests/bats/validate/fixtures/config"
  export GOVCMS_CORE_EXTENTION_FILE_NAME="core.extension-no-disallowed-modules.yml"

  run scripts/validate/govcms-validate-modules >&3

  assert_output_contains "[success]: All modules are in expected states"
  assert_success
}
