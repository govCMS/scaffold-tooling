#!/usr/bin/env bats

load ../_helpers_govcms

# Ensure that session configuration is as expected.
@test "All services session config" {
  [ "$(yq r drupal/settings/all.services.yml "parameters[session.storage.options].gc_maxlifetime")" -eq 1440 ];
  [ "$(yq r drupal/settings/all.services.yml "parameters[session.storage.options].gc_divisor")" -eq 100 ];
  [ "$(yq r drupal/settings/all.services.yml "parameters[session.storage.options].gc_probability")" -eq 1 ];
  [ "$(yq r drupal/settings/all.services.yml "parameters[session.storage.options].cookie_lifetime")" -eq 0 ];
}
