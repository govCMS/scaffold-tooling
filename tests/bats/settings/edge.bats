#!/usr/bin/env bats

load ../_helpers_govcms

setup() {
  PROJECT_DIR=$(pwd)
  if [ ! -f "/tmp/bats/all.settings.php" ]; then
    mkdir -p /tmp/bats
    (cd /tmp/bats && cp ${PROJECT_DIR}/drupal/settings/all.settings.php .)
  fi

  if [ ! -f "/tmp/bats/lagoon.settings.php" ]; then
    mkdir -p /tmp/bats
    (cd /tmp/bats && cp ${PROJECT_DIR}/drupal/settings/lagoon.settings.php .)
  fi
}

all_settings() {
  JSON=$(./tests/drupal-settings-to-json.php /tmp/bats/all.settings.php)
  echo "$JSON"
}

lagoon_settings() {
  JSON=$(./tests/drupal-settings-to-json.php /tmp/bats/lagoon.settings.php)
  echo "$JSON"
}

@test "Akamai friendly caching" {
  SETTINGS=$(
    LAGOON=true \
    all_settings | jq -rc .settings
  )
  [ "$(echo "$SETTINGS" | jq .page_cache_invoke_hooks)" == "true" ]
  [ "$(echo "$SETTINGS" | jq .redirect_page_cache)" == "true" ]
}

@test "Varnish settings" {
  SETTINGS=$(
    LAGOON=true \
    VARNISH_CONTROL_PORT="4041" \
    VARNISH_HOSTS="chip,dale" \
    VARNISH_SECRET=shhhh \
    lagoon_settings | jq -rc .settings
  )

  [ "$(echo "$SETTINGS" | jq -rc .varnish_control_terminal)" == 'chip:4041 dale:4041' ]
  [ "$(echo "$SETTINGS" | jq -rc .varnish_control_key)" == "shhhh" ]
  [ "$(echo "$SETTINGS" | jq -rc .varnish_version)" == 4 ]
  [ "$(echo "$SETTINGS" | jq -rc .reverse_proxy_addresses)" == '["chip","dale","varnish"]' ]
  [ "$(echo "$SETTINGS" | jq -rc .reverse_proxy)" == "true" ]
}
