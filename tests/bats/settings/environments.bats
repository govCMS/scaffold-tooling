#!/usr/bin/env bats

load ../_helpers_govcms

setup() {
  PROJECT_DIR=$(pwd)
  if [ ! -f "/tmp/bats/settings.php" ]; then
    mkdir -p /tmp/bats
    (cd /tmp/bats && cp "${PROJECT_DIR}"/drupal/settings/settings.php .)
    sed -i.bak 's/govcms_includes =.*/govcms_includes = "\/tmp\/bats";/g' /tmp/bats/settings.php
  fi

  if [ ! -f "/tmp/bats/all.settings.php" ]; then
    mkdir -p /tmp/bats
    (cd /tmp/bats && cp "${PROJECT_DIR}"/drupal/settings/all.settings.php .)
  fi

  if [ ! -f "/tmp/bats/development.settings.php" ]; then
    mkdir -p /tmp/bats
    (cd /tmp/bats && cp "${PROJECT_DIR}"/drupal/settings/development.settings.php .)
  fi

  if [ ! -f "/tmp/bats/production.settings.php" ]; then
    mkdir -p /tmp/bats
    (cd /tmp/bats && cp "${PROJECT_DIR}"/drupal/settings/production.settings.php .)
  fi

  if [ ! -f "/tmp/bats/lagoon.settings.php" ]; then
    mkdir -p /tmp/bats
    (cd /tmp/bats && cp "${PROJECT_DIR}"/drupal/settings/lagoon.settings.php .)
  fi

  if [ ! -f "/tmp/bats/dev-mode.settings.php" ]; then
    mkdir -p /tmp/bats
    (cd /tmp/bats && cp "${PROJECT_DIR}"/drupal/settings/dev-mode.settings.php .)
  fi
}

settings() {
  JSON=$(./tests/drupal-settings-to-json.php /tmp/bats/settings.php)
  echo "$JSON"
}

@test "Correct includes in dev mode (not lagoon)" {
  FILES=$(
    unset LAGOON
    DEV_MODE='true' \
    LAGOON_ENVIRONMENT_TYPE=development \
    settings | jq .included_files
  )

  [ "$(echo "$FILES" | jq '. | has("all.settings.php")')" == "true" ]
  [ "$(echo "$FILES" | jq '. | has("lagoon.settings.php")')" == "false" ]
  [ "$(echo "$FILES" | jq '. | has("production.settings.php")')" == "false" ]
  [ "$(echo "$FILES" | jq '. | has("development.settings.php")')" == "true" ]
  [ "$(echo "$FILES" | jq '. | has("dev-mode.settings.php")')" == "true" ]
}

@test "Correct includes in dev mode (lagoon image)" {
  # shellcheck disable=SC2034
  FILES=$(
    LAGOON=true \
    DEV_MODE=true \
    LAGOON_ENVIRONMENT_TYPE=development \
    settings | jq .included_files
  )

  [ "$(echo "$FILES" | jq '. | has("all.settings.php")')" == "true" ]
  [ "$(echo "$FILES" | jq '. | has("lagoon.settings.php")')" == "true" ]
  [ "$(echo "$FILES" | jq '. | has("production.settings.php")')" == "false" ]
  [ "$(echo "$FILES" | jq '. | has("development.settings.php")')" == "true" ]
  [ "$(echo "$FILES" | jq '. | has("dev-mode.settings.php")')" == "true" ]
}

@test "Correct includes in production mode (not lagoon)" {
  FILES=$(
    unset LAGOON
    unset DEV_MODE
    LAGOON_ENVIRONMENT_TYPE=production \
    settings | jq .included_files
  )
  [ "$(echo "$FILES" | jq '. | has("all.settings.php")')" == "true" ]
  [ "$(echo "$FILES" | jq '. | has("lagoon.settings.php")')" == "false" ]
  [ "$(echo "$FILES" | jq '. | has("production.settings.php")')" == "true" ]
  [ "$(echo "$FILES" | jq '. | has("development.settings.php")')" == "false" ]
}

@test "Correct includes in production mode (lagoon image)" {
  FILES=$(
    unset DEV_MODE
    LAGOON_ENVIRONMENT_TYPE=production \
    LAGOON=true \
    settings | jq .included_files
  )
  [ "$(echo "$FILES" | jq '. | has("all.settings.php")')" == "true" ]
  [ "$(echo "$FILES" | jq '. | has("lagoon.settings.php")')" == "true" ]
  [ "$(echo "$FILES" | jq '. | has("production.settings.php")')" == "true" ]
  [ "$(echo "$FILES" | jq '. | has("development.settings.php")')" == "false" ]
}

@test "Correct yamls dev mode" {
  YAMLS=$(
    DEV_MODE=true \
    LAGOON=true \
    settings | jq -rc .settings.container_yamls
  )

  [[ "$YAMLS" == *"all.services.yml"* ]]
  [[ "$YAMLS" == *"lagoon.services.yml"* ]]
  [[ "$YAMLS" == *"development.services.yml"* ]]
  [[ "$YAMLS" != *"production.services.yml"* ]]
}

@test "Correct yamls production mode" {
  YAMLS=$(
    unset DEV_MODE
    LAGOON=true \
    LAGOON_ENVIRONMENT_TYPE=production \
    settings | jq -rc .settings.container_yamls
  )

  [[ "$YAMLS" == *"all.services.yml"* ]]
  [[ "$YAMLS" == *"lagoon.services.yml"* ]]
  [[ "$YAMLS" != *"development.services.yml"* ]]
  [[ "$YAMLS" == *"production.services.yml"* ]]
}
