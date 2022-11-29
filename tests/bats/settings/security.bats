#!/usr/bin/env bats

# shellcheck disable=SC2086,SC2046

load ../_helpers_govcms

setup() {
  if [ ! -f "/tmp/bats/all.settings.php" ]; then
    mkdir -p /tmp/bats
    cp ./drupal/settings/all.settings.php /tmp/bats/
  fi

  if [ ! -f "/tmp/bats/lagoon.settings.php" ]; then
    mkdir -p /tmp/bats
    cp ./drupal/settings/lagoon.settings.php /tmp/bats/
  fi
}

settings() {
  JSON=$(./tests/drupal-settings-to-json.php /tmp/bats/all.settings.php)
  echo "$JSON"
}

lagoon_settings() {
  JSON=$(./tests/drupal-settings-to-json.php /tmp/bats/lagoon.settings.php)
  echo "$JSON"
}

security_settings() {
  JSON=$(./tests/drupal-settings-to-json.php $PWD/drupal/settings/security.settings.php)
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
    lagoon_settings | jq -rc '.config | "\(.["clamav.settings"])"'
  )
  [ "$(echo "$SOLR" | jq -rc .scan_mode)" == 1 ]
  [ "$(echo "$SOLR" | jq -rc .mode_executable.executable_path)" == "/usr/bin/clamscan" ]
}

@test "Module permission settings" {
  [ $(security_settings | jq -rc '.config."module_permissions.settings".managed_modules | index( "bigmenu" )') != 'null' ]
  [ $(security_settings | jq -rc '.config."module_permissions.settings".protected_modules | index( "module_permissions" )') != 'null' ]
  [ $(security_settings | jq -rc '.config."module_permissions.settings".protected_modules | index( "module_permissions_ui" )') != 'null' ]
  [ $(security_settings | jq -rc '.config."module_permissions.settings".permission_blacklist | index( "administer modules" )') != 'null' ]
  [ $(security_settings | jq -rc '.config."module_permissions.settings".permission_blacklist | index( "administer permissions" )') != 'null' ]
}
