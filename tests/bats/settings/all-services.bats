#!/usr/bin/env bats

load ../_helpers_govcms

# Ensure that session configuration is as expected.
@test "All services session config" {
  [ "$(yq '.parameters."session.storage.options".gc_maxlifetime' drupal/settings/all.services.yml)" -eq 3600 ];
  [ "$(yq '.parameters."session.storage.options".gc_divisor' drupal/settings/all.services.yml)" -eq 100 ];
  [ "$(yq '.parameters."session.storage.options".gc_probability' drupal/settings/all.services.yml)" -eq 1 ];
  [ "$(yq '.parameters."session.storage.options".cookie_lifetime' drupal/settings/all.services.yml)" -eq 0 ];
}
