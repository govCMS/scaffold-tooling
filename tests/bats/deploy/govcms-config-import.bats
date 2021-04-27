#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030,SC2034,SC2155

load ../_helpers_govcms

################################################################################
#                               DEFAULTS                                       #
################################################################################

# Workflow: import
# dir: /app/config/default
@test "Config import: defaults" {
  mock_drush=$(mock_command "drush")

  run scripts/deploy/govcms-config-import >&3

  assert_output_contains "GovCMS Deploy :: Configuration import"
  assert_output_contains "[skip]: There is no configuration."

  assert_equal 0 "$(mock_get_call_num "${mock_drush}")"
}

# Workflow: retain
# dir: /app/config/default
@test "Config import: retain" {
  mock_drush=$(mock_command "drush")
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=retain

  run scripts/deploy/govcms-config-import >&3

  assert_output_contains "GovCMS Deploy :: Configuration import"
  assert_output_contains "[skip]: Workflow is not set to import."

  assert_equal 0 "$(mock_get_call_num "${mock_drush}")"
}

# Workflow: import
# dir: /app/config/default
@test "Config import: import" {
  mock_drush=$(mock_command "drush")
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=import

  run scripts/deploy/govcms-config-import >&3

  assert_output_contains "GovCMS Deploy :: Configuration import"
  assert_output_contains "[skip]: There is no configuration."

  assert_equal 0 "$(mock_get_call_num "${mock_drush}")"
}

# Workflow: import
# dir: ./fixures/config/default
@test "Config import: default config" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 1

  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=import
  export CONFIG_DEFAULT_DIR="tests/bats/deploy/fixtures/config/default"
  export CONFIG_DEV_DIR="/tmp/nodir"

  run scripts/deploy/govcms-config-import >&3

  assert_output_contains "GovCMS Deploy :: Configuration import"
  assert_output_contains "[update]: Import site configuration."

  assert_equal "config:import -y sync" "$(mock_get_call_args "${mock_drush}" 2)"
  assert_equal 2 "$(mock_get_call_num "${mock_drush}")"
}

# Workflow: import
# dir: /app/config/default
# devdir: ./fixtures/config/dev
@test "Config import: dev config (production)" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 1

  export LAGOON_ENVIRONMENT_TYPE="production"
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=import
  export CONFIG_DEV_DIR="tests/bats/deploy/fixtures/config/dev"

  run scripts/deploy/govcms-config-import >&3

  assert_output_contains "GovCMS Deploy :: Configuration import"
  assert_output_contains "[success]: Completed successfully."

  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"
}

# Workflow: import
# dir: /app/config/default
# devdir: ./fixtures/config/dev
@test "Config import: dev config (nonprod)" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 1

  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=import
  export CONFIG_DEV_DIR="tests/bats/deploy/fixtures/config/dev"
  export LAGOON_ENVIRONMENT_TYPE="development"

  run scripts/deploy/govcms-config-import >&3

  assert_output_contains "GovCMS Deploy :: Configuration import"
  assert_output_contains "[update]: Import dev configuration partially."
  assert_output_contains "[success]: Completed successfully."

  assert_equal "config:import -y dev --partial" "$(mock_get_call_args "${mock_drush}" 2)"
  assert_equal 2 "$(mock_get_call_num "${mock_drush}")"
}

# Workflow: import
# dir: ./fixures/config/default
# devdir: ./fixtures/config/dev
@test "Config import: both dirs available (production)" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 1

  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=import
  export LAGOON_ENVIRONMENT_TYPE="production"
  export CONFIG_DEFAULT_DIR="tests/bats/deploy/fixtures/config/default"
  export CONFIG_DEV_DIR="tests/bats/deploy/fixtures/config/dev"

  run scripts/deploy/govcms-config-import >&3

  assert_output_contains "GovCMS Deploy :: Configuration import"
  assert_output_contains "[update]: Import site configuration."
  assert_output_contains "[success]: Completed successfully."

  assert_equal "config:import -y sync" "$(mock_get_call_args "${mock_drush}" 2)"
  assert_equal 2 "$(mock_get_call_num "${mock_drush}")"
}

# Workflow: import
# dir: ./fixures/config/default
# devdir: ./fixtures/config/dev
@test "Config import: both dirs available (nonprod)" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" "Successful" 1

  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=import
  export LAGOON_ENVIRONMENT_TYPE="development"
  export CONFIG_DEFAULT_DIR="tests/bats/deploy/fixtures/config/default"
  export CONFIG_DEV_DIR="tests/bats/deploy/fixtures/config/dev"

  run scripts/deploy/govcms-config-import >&3

  assert_output_contains "GovCMS Deploy :: Configuration import"
  assert_output_contains "[update]: Import site configuration."
  assert_output_contains "[update]: Import dev configuration partially."
  assert_output_contains "[success]: Completed successfully."

  assert_equal "config:import -y sync" "$(mock_get_call_args "${mock_drush}" 2)"
  assert_equal "config:import -y dev --partial" "$(mock_get_call_args "${mock_drush}" 3)"
  assert_equal 3 "$(mock_get_call_num "${mock_drush}")"
}

# Workflow: import
# branch: update pattern
@test "Config import: upgrade branch" {
  mock_drush=$(mock_command "drush")
  export LAGOON_GIT_SAFE_BRANCH=internal-govcms-update-2-x-master

  run scripts/deploy/govcms-config-import >&3

  assert_output_contains "GovCMS Deploy :: Configuration import"
  assert_output_contains "[skip]: Configuration cannot be imported on update branches."
}
