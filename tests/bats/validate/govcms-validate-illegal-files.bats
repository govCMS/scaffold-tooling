#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030,SC2155

load ../_helpers_govcms

@test "Illegal files: success" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures/module -type f)

  run scripts/validate/govcms-validate-illegal-files >&3

  assert_output_contains "GovCMS Validate :: Illegal files"
  assert_output_contains "[success]: No illegal files."
  assert_success
}


@test "Illegal Files: adminer" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures/illegal_files/a -type f)

  run scripts/validate/govcms-validate-illegal-files >&3

  assert_output_contains "GovCMS Validate :: Illegal files"
  assert_output_contains "[fail]: Illegal file found [tests/bats/validate/fixtures/illegal_files/a/adminer.php]"
  assert_failure

}

@test "Illegal Files: adminer pattern" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures/illegal_files/b -type f)

  run scripts/validate/govcms-validate-illegal-files >&3

  assert_output_contains "GovCMS Validate :: Illegal files"
  assert_output_contains "[fail]: Illegal file found [tests/bats/validate/fixtures/illegal_files/b/adminer-4.4.4.php]"
  assert_failure

}

@test "Illegal Files: bigdump" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures/illegal_files/c -type f)

  run scripts/validate/govcms-validate-illegal-files >&3

  assert_output_contains "GovCMS Validate :: Illegal files"
  assert_output_contains "[fail]: Illegal file found [tests/bats/validate/fixtures/illegal_files/c/bigdump.php]"
  assert_failure

}

@test "Illegal Files: bigdump pattern" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures/illegal_files/d -type f)

  run scripts/validate/govcms-validate-illegal-files >&3

  assert_output_contains "GovCMS Validate :: Illegal files"
  assert_output_contains "[fail]: Illegal file found [tests/bats/validate/fixtures/illegal_files/d/bigdump-v2.php]"
  assert_failure

}

@test "Illegal Files: phpmyadmin" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures/illegal_files/e -type f)

  run scripts/validate/govcms-validate-illegal-files >&3

  assert_output_contains "GovCMS Validate :: Illegal files"
  assert_output_contains "[fail]: Illegal file found [tests/bats/validate/fixtures/illegal_files/e/phpmyadmin.php]"
  assert_failure

}
