#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030,SC2155

load ../_helpers_govcms

@test "No exported config files." {
  export GOVCMS_CONFIG_FOLDER_PATH="tests/bats/validate/fixtures/config"
  export GOVCMS_CORE_EXTENTION_FILE_NAME=""
  export GOVCMS_DISALLOWED_MODULES="update
  dblog
  "
  run scripts/validate/govcms-validate-modules >&3

  assert_output_contains "Coudn't find core.extension.yml file."
  assert_success
}

@test "Config has a disallowed module." {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures/module -type f)
  export GOVCMS_CONFIG_FOLDER_PATH="tests/bats/validate/fixtures/config"
  export GOVCMS_CORE_EXTENTION_FILE_NAME="core.extension-with-disallowed-modules.yml"
  export GOVCMS_DISALLOWED_MODULES="update
  dblog
  "
  run scripts/validate/govcms-validate-modules >&3

  assert_output_contains "[fail]: Found disallowed modules in the exported config files: update, dblog."
  assert_failure
}

@test "Config doesn't have a disallowed module." {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures/module -type f)
  export GOVCMS_CONFIG_FOLDER_PATH="tests/bats/validate/fixtures/config"
  export GOVCMS_CORE_EXTENTION_FILE_NAME="core.extension-no-disallowed-modules.yml"
  export GOVCMS_DISALLOWED_MODULES="update
  dblog
  "
  run scripts/validate/govcms-validate-modules >&3

  assert_output_contains "[success]: No disallowed module found in the exported config files."
  assert_success
}
