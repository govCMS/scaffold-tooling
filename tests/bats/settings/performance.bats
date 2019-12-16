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

# Need to mock or fake the class loader.
#
#@test "Redis loaded" {
#  REDIS=$(
#    ENABLE_REDIS=true \
#    REDIS_HOST="alt-host" \
#    LAGOON=true \
#    settings | jq -rc '.config | "\(.["redis.connection"])"'
#  )
#
#  [ $(echo $REDIS | jq -rc .interface) == "PhpRedis" ]
#  [ $(echo $REDIS | jq -rc .host) == "alt-host" ]
#  [ $(echo $REDIS | jq -rc .port) == 6379 ]
#}


@test "System performance settings for prod" {
  PERF=$(
    LAGOON_ENVIRONMENT_TYPE=production \
    settings | jq -rc '.config | "\(.["system.performance"])"'
  )
  [ $(echo $PERF | jq -rc .cache.page.max_age) == 900 ]
  [ $(echo $PERF | jq -rc .css.preprocess) == 1 ]
  [ $(echo $PERF | jq -rc .js.preprocess) == 1 ]
}
