#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030

load ../_helpers_govcms

@test "Check disallowed permissions on active site: defaults" {
  run scripts/validate/govcms-validate-active-permissions >&3
  assert_output_contains "GovCMS Validate :: Disallowed permissions on active site"
}

@test "Check disallowed permissions on active site: pass" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "{  }" 1

  run scripts/validate/govcms-validate-active-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions on active site"
  assert_output_contains "[success]: No elevated permissions detected in configuration."
  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"
}

@test "Check disallowed permissions on active site: administer permissions" {
  DRUSH_OUTPUT=$(cat tests/bats/validate/fixtures/disallowed-admin_permissions.json)
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "${DRUSH_OUTPUT}" 1

  run scripts/validate/govcms-validate-active-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions on active site"
  assert_output_contains "[fail]: 'anonymous' has restricted permissions"
  assert_output_contains "[fail]: 'authenticated' has restricted permissions"
  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"
}

@test "Check disallowed permissions on active site: administer modules" {
  DRUSH_OUTPUT=$(cat tests/bats/validate/fixtures/disallowed-admin_modules.json)
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "${DRUSH_OUTPUT}" 1

  run scripts/validate/govcms-validate-active-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions on active site"
  assert_output_contains "[fail]: 'anonymous' has restricted permissions"
  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"
}

@test "Check disallowed permissions on active site: administer software updates" {
  DRUSH_OUTPUT=$(cat tests/bats/validate/fixtures/disallowed-admin_updates.json)
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "${DRUSH_OUTPUT}" 1

  run scripts/validate/govcms-validate-active-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions on active site"
  assert_output_contains "[fail]: 'anonymous' has restricted permissions"
  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"
}

@test "Check disallowed permissions on active site: administer site configuration" {
  DRUSH_OUTPUT=$(cat tests/bats/validate/fixtures/disallowed-admin_site_configuration.json)
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "${DRUSH_OUTPUT}" 1

  run scripts/validate/govcms-validate-active-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions on active site"
  assert_output_contains "[fail]: 'anonymous' has restricted permissions"
  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"
}

@test "Check disallowed permissions on active site: use PHP for google analytics tracking visibility" {
  DRUSH_OUTPUT=$(cat tests/bats/validate/fixtures/disallowed-admin_ga_php.json)
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "${DRUSH_OUTPUT}" 1

  run scripts/validate/govcms-validate-active-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions on active site"
  assert_output_contains "[fail]: 'anonymous' has restricted permissions"
  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"
}

@test "Check disallowed permissions on active site: import configuration" {
  DRUSH_OUTPUT=$(cat tests/bats/validate/fixtures/disallowed-admin_import_config.json)
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "${DRUSH_OUTPUT}" 1

  run scripts/validate/govcms-validate-active-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions on active site"
  assert_output_contains "[fail]: 'anonymous' has restricted permissions"
  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"
}

@test "Check disallowed permissions on active site: Administer the list of modules that can be managed by others" {
  DRUSH_OUTPUT=$(cat tests/bats/validate/fixtures/disallowed-module_permissions_ui.json)
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "${DRUSH_OUTPUT}" 1

  run scripts/validate/govcms-validate-active-permissions >&3

  assert_output_contains "GovCMS Validate :: Disallowed permissions on active site"
  assert_output_contains "[fail]: 'anonymous' has restricted permissions"
  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"
}
