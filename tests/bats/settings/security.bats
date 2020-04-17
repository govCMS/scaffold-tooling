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

@test "Seckit default off" {
  SECKIT=$(
    HTTP_HOST=anything.com.au \
    settings | jq -rc '.config | "\(.["seckit.settings"]["seckit_ssl"])"'
  )
  echo "$SECKIT" | jq .hsts
  [ "$(echo "$SECKIT" | jq .hsts)" == "false" ]
  [ "$(echo "$SECKIT" | jq .hsts_max_age)" -eq 0 ]
}

@test "Seckit on gov.au" {
  SECKIT=$(
    HTTP_HOST=anything.gov.au \
    settings | jq -rc '.config | "\(.["seckit.settings"]["seckit_ssl"])"'
  )
  [ "$(echo "$SECKIT" | jq .hsts)" == "true" ]
  [ "$(echo "$SECKIT" | jq .hsts_max_age)" -eq 31536000 ]
}

@test "Seckit on org.au" {
  SECKIT=$(
    HTTP_HOST=anything.org.au \
    settings | jq -rc '.config | "\(.["seckit.settings"]["seckit_ssl"])"'
  )
  [ "$(echo "$SECKIT" | jq .hsts)" == "true" ]
  [ "$(echo "$SECKIT" | jq .hsts_max_age)" -eq 31536000 ]
}

@test "Clam AV settings" {
  SOLR=$(
    LAGOON=true \
    settings | jq -rc '.config | "\(.["clamav.settings"])"'
  )
  [ "$(echo "$SOLR" | jq -rc .scan_mode)" == 1 ]
  [ "$(echo "$SOLR" | jq -rc .mode_executable.executable_path)" == "/usr/bin/clamscan" ]
}
