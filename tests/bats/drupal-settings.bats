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

@test "GA disabled for dev" {
  DEV1=$(
    LAGOON_ENVIRONMENT_TYPE=development \
    settings | jq -rc '.config | "\(.["google_analytics.settings"])"'
  )
  DEV2=$(
    DEV_MODE=true \
    settings | jq -rc '.config | "\(.["google_analytics.settings"])"'
  )
  [ $(echo $DEV1 | jq -rc .account) == "UA-XXXXXXXX-YY" ]
  [ $(echo $DEV2 | jq -rc .account) == "UA-XXXXXXXX-YY" ]
}

@test "GA settings for prod" {
  SNIPPET=$(
    LAGOON_ENVIRONMENT_TYPE=production \
    settings | jq -rc '.config | "\(.["google_analytics.settings"]["codesnippet"]["after"])"'
  )
  [[ "$SNIPPET" == *"gtag('config', 'UA-54970022-1', {'name': 'govcms'})"* ]]
  [[ "$SNIPPET" == *"gtag('govcms.send', 'pageview', {'anonymizeIp': true})"* ]]
}

@test "Performance settings for prod" {
  PERF=$(
    LAGOON_ENVIRONMENT_TYPE=production \
    settings | jq -rc '.config | "\(.["system.performance"])"'
  )
  [ $(echo $PERF | jq -rc .cache.page.max_age) == 900 ]
  [ $(echo $PERF | jq -rc .css.preprocess) == 1 ]
  [ $(echo $PERF | jq -rc .js.preprocess) == 1 ]
}

@test "Stage file proxy settings for prod" {
  SFP=$(
    LAGOON_ENVIRONMENT_TYPE=production \
    settings | jq -rc '.config | "\(.["stage_file_proxy.settings"])"'
  )
  [ $(echo $SFP | jq -rc .origin) == "false" ]
}

@test "Stage file proxy settings for dev" {
  SFP_DEFAULT=$(
    LAGOON_PROJECT=govcmsd8 \
    LAGOON_ENVIRONMENT_TYPE=development \
    settings | jq -rc '.config | "\(.["stage_file_proxy.settings"])"'
  )
  SFP_OVERRIDE=$(
    LAGOON_PROJECT=should-not-use \
    STAGE_FILE_PROXY_URL="https://www.govcms.gov.au" \
    LAGOON_ENVIRONMENT_TYPE=development \
    settings | jq -rc '.config | "\(.["stage_file_proxy.settings"])"'
  )

  [ $(echo $SFP_DEFAULT | jq -rc .origin) == "https://nginx-govcmsd8-master.govcms.amazee.io" ]
  [ $(echo $SFP_OVERRIDE | jq -rc .origin) == "https://www.govcms.gov.au" ]
}
