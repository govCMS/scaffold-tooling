#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030,SC2155

load ../_helpers_govcms

@test "Check disallowed permissions: defaults" {
  run scripts/validate/govcms-validate-permissions >&3
  assert_output_contains "GovCMS Validate :: Disallowed permissions"

  assert_failure
}

@test "Check disallowed permissions: pass" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "user.role.example.yml" \) -print0)

  run scripts/validate/govcms-validate-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions"
  assert_output_contains "[success]: No elevated permissions detected in configuration."

  assert_success
}

@test "Check disallowed permissions: administer permissions" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "user.role.admin_permissions.yml" \) -print0)

  run scripts/validate/govcms-validate-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions"
  assert_output_contains "[fail]: $GOVCMS_FILE_LIST has restricted permissions: \"administer permissions\""

  assert_failure
}

@test "Check disallowed permissions: administer modules" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "user.role.admin_modules.yml" \) -print0)

  run scripts/validate/govcms-validate-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions"
  assert_output_contains "[fail]: $GOVCMS_FILE_LIST has restricted permissions: \"administer modules\""

  assert_failure
}

@test "Check disallowed permissions: administer software updates" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "user.role.admin_updates.yml" \) -print0)

  run scripts/validate/govcms-validate-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions"
  assert_output_contains "[fail]: $GOVCMS_FILE_LIST has restricted permissions: \"administer software updates\""

  assert_failure
}

@test "Check disallowed permissions: administer site configuration" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "user.role.admin_site_configuration.yml" \) -print0)

  run scripts/validate/govcms-validate-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions"
  assert_output_contains "[fail]: $GOVCMS_FILE_LIST has restricted permissions: \"administer site configuration\""

  assert_failure
}

@test "Check disallowed permissions: use PHP for google analytics tracking visibility" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "user.role.admin_ga_php.yml" \) -print0)

  run scripts/validate/govcms-validate-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions"
  assert_output_contains "[fail]: $GOVCMS_FILE_LIST has restricted permissions: \"use PHP for google analytics tracking visibility\""

  assert_failure
}

@test "Check disallowed permissions: import configuration" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "user.role.admin_import_config.yml" \) -print0)

  run scripts/validate/govcms-validate-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions"
  assert_output_contains "[fail]: $GOVCMS_FILE_LIST has restricted permissions: \"import configuration\""

  assert_failure
}

@test "Check disallowed permissions: is_admin" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "user.role.is_admin.yml" \) -print0)

  run scripts/validate/govcms-validate-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions"
  assert_output_contains "[fail]: $GOVCMS_FILE_LIST is listed as an admin role"

  assert_failure
}

@test "Check disallowed permissions: module_permissions_ui" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "user.role.module_permissions_ui.yml" \) -print0)

  run scripts/validate/govcms-validate-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions"
  assert_output_contains "[fail]: $GOVCMS_FILE_LIST has restricted permissions: \"Administer the list of modules that can be managed by others\""

  assert_failure
}

@test "Check disallowed permissions: multiple files" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "user.role.example.yml" -or -name "user.role.is_admin.yml" \))

  run scripts/validate/govcms-validate-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions"
  assert_output_contains "[fail]: tests/bats/validate/fixtures/user.role.is_admin.yml is listed as an admin role"

  assert_failure
}

@test "Check disallowed permissions: multiple permissions" {
  export GOVCMS_FILE_LIST=$(find tests/bats/validate/fixtures -type f \( -name "user.role.multiple_perms.yml" \))

  run scripts/validate/govcms-validate-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions"
  assert_output_contains "[fail]: tests/bats/validate/fixtures/user.role.multiple_perms.yml has restricted permissions: \"administer site configuration,administer software updates\""

  assert_failure
}
