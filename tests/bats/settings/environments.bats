#!/usr/bin/env bats

setup() {
  if [ ! -f "/tmp/bats/settings.php" ]; then
    mkdir -p /tmp/bats
    (cd /tmp/bats && curl -O https://raw.githubusercontent.com/simesy/govcms8-scaffold/paas-saas-mash-up/web/sites/default/settings.php)
  fi
}

settings() {
  JSON=$(./tests/drupal-settings-to-json.php)
  echo "$JSON"
}

@test "Correct includes in dev mode (not lagoon)" {
  FILES=$(
    unset LAGOON
    DEV_MODE=true \
    LAGOON_ENVIRONMENT_TYPE=production \
    settings | jq .included_files
  )

  [ "$(echo "$FILES" | jq '. | has("all.settings.php")')" == "true" ]
  [ "$(echo "$FILES" | jq '. | has("lagoon.settings.php")')" == "false" ]
  [ "$(echo "$FILES" | jq '. | has("production.settings.php")')" == "false" ]
  [ "$(echo "$FILES" | jq '. | has("development.settings.php")')" == "true" ]
}

@test "Correct includes in dev mode (lagoon image)" {
  # shellcheck disable=SC2034
  FILES=$(
    LAGOON=true \
    DEV_MODE=true \
    LAGOON_ENVIRONMENT_TYPE=production \
    settings | jq .included_files
  )

  [ "$(echo "$FILES" | jq '. | has("all.settings.php")')" == "true" ]
  [ "$(echo "$FILES" | jq '. | has("lagoon.settings.php")')" == "true" ]
  [ "$(echo "$FILES" | jq '. | has("production.settings.php")')" == "false" ]
  [ "$(echo "$FILES" | jq '. | has("development.settings.php")')" == "true" ]
}

@test "Correct includes in production mode (not lagoon)" {
  FILES=$(
    unset LAGOON
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
    LAGOON=true \
    LAGOON_ENVIRONMENT_TYPE=production \
    settings | jq -rc .settings.container_yamls
  )

  [[ "$YAMLS" == *"all.services.yml"* ]]
  [[ "$YAMLS" == *"lagoon.services.yml"* ]]
  [[ "$YAMLS" != *"development.services.yml"* ]]
  [[ "$YAMLS" == *"production.services.yml"* ]]
}
