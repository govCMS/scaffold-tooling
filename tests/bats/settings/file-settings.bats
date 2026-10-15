#!/usr/bin/env bats

load ../_helpers_govcms

setup() {
  PROJECT_DIR=$(pwd)
  if [ ! -f "/tmp/bats/production.settings.php" ]; then
    mkdir -p /tmp/bats
    (cd /tmp/bats && cp "${PROJECT_DIR}"/drupal/settings/production.settings.php .)
  fi
}

settings() {
  JSON=$(./tests/drupal-settings-to-json.php /tmp/bats/production.settings.php)
  echo "$JSON"
}

@test "No GOVCMS_FILE_TEMP_MAX_AGE for prod" {
  CONFIG=$(
    LAGOON_ENVIRONMENT_TYPE=production \
    settings | jq -rc '.config'
  )

  [ "$(echo "$CONFIG" | jq '. | has("system.file")')" == "false" ]
}

@test "Test GOVCMS_FILE_TEMP_MAX_AGE=-1 for prod" {
  CONFIG=$(
    LAGOON_ENVIRONMENT_TYPE=production \
    GOVCMS_FILE_TEMP_MAX_AGE=-1 \
    settings | jq -rc '.config'
  )

  [ "$(echo "$CONFIG" | jq '. | has("system.file")')" == "false" ]
}

@test "Test GOVCMS_FILE_TEMP_MAX_AGE=0 for prod" {
  FILE=$(
    LAGOON_ENVIRONMENT_TYPE=production \
    GOVCMS_FILE_TEMP_MAX_AGE=0 \
    settings | jq -rc '.config | "\(.["system.file"])"'
  )

  [ "$(echo "$FILE" | jq -rc .temporary_maximum_age)" == 0 ]
}

@test "Test GOVCMS_FILE_TEMP_MAX_AGE=0.5 for prod" {
  FILE=$(
    LAGOON_ENVIRONMENT_TYPE=production \
    GOVCMS_FILE_TEMP_MAX_AGE=0.5 \
    settings | jq -rc '.config | "\(.["system.file"])"'
  )

  [ "$(echo "$FILE" | jq -rc .temporary_maximum_age)" == 0 ]
}

@test "Test GOVCMS_FILE_TEMP_MAX_AGE=1.5 for prod" {
  FILE=$(
    LAGOON_ENVIRONMENT_TYPE=production \
    GOVCMS_FILE_TEMP_MAX_AGE=1.5 \
    settings | jq -rc '.config | "\(.["system.file"])"'
  )

  [ "$(echo "$FILE" | jq -rc .temporary_maximum_age)" == 1 ]
}

@test "Test GOVCMS_FILE_TEMP_MAX_AGE=3600 for prod" {
  FILE=$(
    LAGOON_ENVIRONMENT_TYPE=production \
    GOVCMS_FILE_TEMP_MAX_AGE=3600 \
    settings | jq -rc '.config | "\(.["system.file"])"'
  )

  [ "$(echo "$FILE" | jq -rc .temporary_maximum_age)" == 3600 ]
}

@test "Test GOVCMS_FILE_TEMP_MAX_AGE=invalid for prod" {
  CONFIG=$(
    LAGOON_ENVIRONMENT_TYPE=production \
    GOVCMS_FILE_TEMP_MAX_AGE=invalid \
    settings | jq -rc '.config'
  )
  [ "$(echo "$CONFIG" | jq '. | has("system.file")')" == "false" ]
}

@test "No GOVCMS_MAKE_UNUSED_FILES_TEMP for prod" {
  FILE=$(
    LAGOON_ENVIRONMENT_TYPE=production \
    settings | jq -rc '.config | "\(.["file.settings"])"'
  )

  [ "$(echo "$FILE" | jq -rc .make_unused_managed_files_temporary)" == "false" ]
}

@test "Test GOVCMS_MAKE_UNUSED_FILES_TEMP=true for prod" {
  FILE=$(
    LAGOON_ENVIRONMENT_TYPE=production \
    GOVCMS_MAKE_UNUSED_FILES_TEMP=true \
    settings | jq -rc '.config | "\(.["file.settings"])"'
  )

  [ "$(echo "$FILE" | jq -rc .make_unused_managed_files_temporary)" == "true" ]
}

@test "Test GOVCMS_MAKE_UNUSED_FILES_TEMP=TRUE for prod" {
  FILE=$(
    LAGOON_ENVIRONMENT_TYPE=production \
    GOVCMS_MAKE_UNUSED_FILES_TEMP=TRUE \
    settings | jq -rc '.config | "\(.["file.settings"])"'
  )

  [ "$(echo "$FILE" | jq -rc .make_unused_managed_files_temporary)" == "false" ]
}

@test "Test GOVCMS_MAKE_UNUSED_FILES_TEMP=1 for prod" {
  FILE=$(
    LAGOON_ENVIRONMENT_TYPE=production \
    GOVCMS_MAKE_UNUSED_FILES_TEMP=1 \
    settings | jq -rc '.config | "\(.["file.settings"])"'
  )

  [ "$(echo "$FILE" | jq -rc .make_unused_managed_files_temporary)" == "false" ]
}

@test "Test GOVCMS_MAKE_UNUSED_FILES_TEMP=false for prod" {
  FILE=$(
    LAGOON_ENVIRONMENT_TYPE=production \
    GOVCMS_MAKE_UNUSED_FILES_TEMP=false \
    settings | jq -rc '.config | "\(.["file.settings"])"'
  )

  [ "$(echo "$FILE" | jq -rc .make_unused_managed_files_temporary)" == "false" ]
}

@test "Test GOVCMS_MAKE_UNUSED_FILES_TEMP=0 for prod" {
  FILE=$(
    LAGOON_ENVIRONMENT_TYPE=production \
    GOVCMS_MAKE_UNUSED_FILES_TEMP=0 \
    settings | jq -rc '.config | "\(.["file.settings"])"'
  )

  [ "$(echo "$FILE" | jq -rc .make_unused_managed_files_temporary)" == "false" ]
}

@test "Test GOVCMS_MAKE_UNUSED_FILES_TEMP=anything for prod" {
  FILE=$(
    LAGOON_ENVIRONMENT_TYPE=production \
    GOVCMS_MAKE_UNUSED_FILES_TEMP=anything \
    settings | jq -rc '.config | "\(.["file.settings"])"'
  )

  [ "$(echo "$FILE" | jq -rc .make_unused_managed_files_temporary)" == "false" ]
}
