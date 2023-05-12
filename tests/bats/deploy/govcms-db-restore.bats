#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030

load ../_helpers_govcms

@test "Restore database: defaults" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1

  run scripts/deploy/govcms-db-restore >&3

  assert_output_contains "GovCMS Deploy :: Restore Database"
  assert_output_contains "[skip]: No backup file has been provided."

  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"
}

@test "Restore database: arguments" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1

  run scripts/deploy/govcms-db-restore arg arg2 >&3

  assert_output_contains "GovCMS Deploy :: Restore Database"
  assert_output_contains "[skip]: Too many arguments, expecting one."

  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"
}

@test "Restore database: confirmation" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1

  run scripts/deploy/govcms-db-restore arg3 /Q>&3

  assert_output_contains "GovCMS Deploy :: Restore Database"
  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"
}

# Workflow: Unsupported file
@test "Restore database: import unsupported" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1

  run scripts/deploy/govcms-db-restore tests/bats/deploy/fixtures/sample_db.txt >&3

  assert_output_contains "GovCMS Deploy :: Restore Database"
  assert_output_contains "[skip]: Unsupported file type."

  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"
}

# Workflow: SQL import
# file: ./fixures/sample_db.sql
@test "Restore database: import" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1

  run scripts/deploy/govcms-db-restore tests/bats/deploy/fixtures/sample_db.sql >&3

  assert_output_contains "GovCMS Deploy :: Restore Database"
  assert_output_contains "[info]: Importing backup file..."

  assert_output_contains "[success]: Completed successfully."
  assert_equal 5 "$(mock_get_call_num "${mock_drush}")"
}

# Workflow: SQL archived import
# file: ./fixures/sample_db.sql.gz
@test "Restore database: import archived SQL.GZ" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1

  run scripts/deploy/govcms-db-restore tests/bats/deploy/fixtures/sample_db.sql.gz >&3

  assert_output_contains "GovCMS Deploy :: Restore Database"
  assert_output_contains "[info]: Importing backup file..."

  assert_output_contains "[success]: Completed successfully."
  assert_equal 5 "$(mock_get_call_num "${mock_drush}")"
}

# Workflow: TAR archived import
# file: ./fixures/sample_db.tar.gz
@test "Restore database: import archived TAR.GZ" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1

  run scripts/deploy/govcms-db-restore tests/bats/deploy/fixtures/sample_db.sql.gz >&3

  assert_output_contains "GovCMS Deploy :: Restore Database"
  assert_output_contains "[info]: Importing backup file..."

  assert_output_contains "[success]: Completed successfully."
  assert_equal 5 "$(mock_get_call_num "${mock_drush}")"
}

@test "Restore database: no bootstrap" {
  mock_drush=$(mock_command "drush")

  run scripts/deploy/govcms-db-restore >&3

  assert_output_contains "GovCMS Deploy :: Restore Database"
  assert_output_contains "[skip]: Site is not available."
  assert_output_not_contains "[info]: Importing backup file..."

  assert_output_not_contains "[success]: Completed successfully."
  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"
}
