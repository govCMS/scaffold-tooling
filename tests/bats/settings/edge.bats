#!/usr/bin/env bats

load ../_helpers_govcms

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

@test "Akamai friendly caching" {
  SETTINGS=$(
    LAGOON=true \
    settings | jq -rc .settings
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
    settings | jq -rc .settings
  )

  [ "$(echo "$SETTINGS" | jq -rc .varnish_control_terminal)" == 'chip:4041 dale:4041' ]
  [ "$(echo "$SETTINGS" | jq -rc .varnish_control_key)" == "shhhh" ]
  [ "$(echo "$SETTINGS" | jq -rc .varnish_version)" == 4 ]
  [ "$(echo "$SETTINGS" | jq -rc .reverse_proxy_addresses)" == '["chip","dale","varnish"]' ]
  [ "$(echo "$SETTINGS" | jq -rc .reverse_proxy)" == "true" ]
}
