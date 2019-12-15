#!/usr/bin/env bats

setup() {
  if [ ! -f "/tmp/bats/settings.php" ]; then
    mkdir -p /tmp/bats
    (cd /tmp/bats && curl -O https://raw.githubusercontent.com/simesy/govcms8-scaffold/paas-saas-mash-up/web/sites/default/settings.php)
  fi
}

settings() {
  JSON=`./tests/drupal-settings-to-json.php`
  echo $JSON
}

@test "Shield settings allows CLI" {
  OUT=$(settings | jq -cr '.config | "\(.["shield.settings"]["allow_cli"])"')
  [ "$OUT" == "true" ]
}

@test "File path is correct" {
  OUT=$(settings | jq -cr .settings.file_public_path)
  [ "$OUT" == "sites/default/files" ]
}

@test "Private file path is correct" {
  OUT=$(settings | jq -cr .settings.file_private_path)
  [ "$OUT" == "sites/default/files/private" ]
}

@test "Tmp file path is correct" {
  OUT=$(settings | jq -cr .settings.file_temporary_path)
  [ "$OUT" == "sites/default/files/private/tmp" ]
}

@test "Correct includes in dev mode" {
  FILES=$(
    unset LAGOON
    DEV_MODE=true \
    LAGOON_ENVIRONMENT_TYPE=production \
    settings | jq .included_files
  )

  [ $(echo $FILES | jq '. | has("all.settings.php")') == "true" ]
  [ $(echo $FILES | jq '. | has("lagoon.settings.php")') == "false" ]
  [ $(echo $FILES | jq '. | has("production.settings.php")') == "false" ]
  [ $(echo $FILES | jq '. | has("development.settings.php")') == "true" ]
}

@test "Correct includes in production mode" {
  FILES=$(
    LAGOON_ENVIRONMENT_TYPE=production \
    LAGOON=true \
    settings | jq .included_files
  )
  [ $(echo $FILES | jq '. | has("all.settings.php")') == "true" ]
  [ $(echo $FILES | jq '. | has("lagoon.settings.php")') == "true" ]
  [ $(echo $FILES | jq '. | has("production.settings.php")') == "true" ]
  [ $(echo $FILES | jq '. | has("development.settings.php")') == "false" ]
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

#@test "Ensure GovCMS 404 class" {
#  @see @todo in all.settings.php
#}

@test "Seckit default off" {
  SECKIT=$(
    HTTP_HOST=anything.com.au \
    settings | jq -rc '.config | "\(.["seckit.settings"]["seckit_ssl"])"'
  )
  echo $SECKIT | jq .hsts
  [ $(echo $SECKIT | jq .hsts) == "false" ]
  [ $(echo $SECKIT | jq .hsts_max_age) -eq 0 ]
}

@test "Seckit on gov.au" {
  SECKIT=$(
    HTTP_HOST=anything.gov.au \
    settings | jq -rc '.config | "\(.["seckit.settings"]["seckit_ssl"])"'
  )
  [ $(echo $SECKIT | jq .hsts) == "true" ]
  [ $(echo $SECKIT | jq .hsts_max_age) -eq 31536000 ]
}

@test "Seckit on org.au" {
  SECKIT=$(
    HTTP_HOST=anything.org.au \
    settings | jq -rc '.config | "\(.["seckit.settings"]["seckit_ssl"])"'
  )
  [ $(echo $SECKIT | jq .hsts) == "true" ]
  [ $(echo $SECKIT | jq .hsts_max_age) -eq 31536000 ]
}

@test "Akamai friendly caching" {
  SETTINGS=$(
    LAGOON=true \
    settings | jq -rc .settings
  )
  [ $(echo $SETTINGS | jq .page_cache_invoke_hooks) == "true" ]
  [ $(echo $SETTINGS | jq .redirect_page_cache) == "true" ]
}
