#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030,SC2155

load ../_helpers_govcms

@test "Check disallowed permissions: defaults" {
  run scripts/validate/govcms-validate-permissions >&3
  assert_output_contains "GovCMS Validate :: Disallowed permissions"
}

@test "Check disallowed permissions: pass" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "user.role.example.yml" \) -print0)

  run scripts/validate/govcms-validate-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions"
  assert_output_contains "[success]: No elevated permissions detected in configuration."
}

@test "Check disallowed permissions: administer permissions" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "user.role.admin_permissions.yml" \) -print0)

  run scripts/validate/govcms-validate-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions"
  assert_output_contains "[fail]: $GOVCMS_FILE_LIST has restricted permissions"
}

@test "Check disallowed permissions: administer modules" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "user.role.admin_modules.yml" \) -print0)

  run scripts/validate/govcms-validate-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions"
  assert_output_contains "[fail]: $GOVCMS_FILE_LIST has restricted permissions"
}

@test "Check disallowed permissions: administer software updates" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "user.role.admin_updates.yml" \) -print0)

  run scripts/validate/govcms-validate-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions"
  assert_output_contains "[fail]: $GOVCMS_FILE_LIST has restricted permissions"
}

@test "Check disallowed permissions: administer site configuration" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "user.role.admin_site_configuration.yml" \) -print0)

  run scripts/validate/govcms-validate-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions"
  assert_output_contains "[fail]: $GOVCMS_FILE_LIST has restricted permissions"
}

@test "Check disallowed permissions: use PHP for google analytics tracking visibility" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "user.role.admin_ga_php.yml" \) -print0)

  run scripts/validate/govcms-validate-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions"
  assert_output_contains "[fail]: $GOVCMS_FILE_LIST has restricted permissions"
}

@test "Check disallowed permissions: import configuration" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "user.role.admin_import_config.yml" \) -print0)

  run scripts/validate/govcms-validate-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions"
  assert_output_contains "[fail]: $GOVCMS_FILE_LIST has restricted permissions"
}

@test "Check disallowed permissions: is_admin" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "user.role.is_admin.yml" \) -print0)

  run scripts/validate/govcms-validate-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions"
  assert_output_contains "[fail]: $GOVCMS_FILE_LIST is listed as an admin role"
}

@test "Check disallowed permissions: multiple files" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "user.role.example.yml" -or -name "user.role.is_admin.yml" \))

  run scripts/validate/govcms-validate-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions"
  assert_output_contains "[fail]: tests/bats/validate/fixtures/user.role.is_admin.yml is listed as an admin role"
}
