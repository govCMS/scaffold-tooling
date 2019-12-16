#!/usr/bin/env bats

HERE="$PWD"
WORKSPACE=/tmp/bats/scaffold

setup() {
  if [ ! -d "$WORKSPACE/.git" ]; then
    rm -Rf "$WORKSPACE"
    git clone https://github.com/govCMS/govcms8-scaffold-paas "$WORKSPACE --quiet"
    cd "$WORKSPACE"
    git tag -f rollback --quiet
  fi

  cd "$WORKSPACE"

  git reset --hard rollback --quiet
  git clean -fd --quiet
}

vet() {
  "$HERE"/scripts/govcms-vet
}

# Documented test template.
#
#@test "Checking that... [vet-???]" {
#  # Move to the directory where we have a copy of the scaffold.
#  cd "$WORKSPACE"
#  # Make an undesirable change...
#  composer config repositories.notallowed composer http://drupal.packagist.org
#  # The vetting script needs any changes to be committed.
#  git add . && git commit -m"$(basename "$0")" --quiet
#
#  # Capture the vet script output.
#  RESULT=$(vet)
#  # See the vet output on a failing bats test.
#  echo "$RESULT"
#
#  [[ "$RESULT" == *"[vet-???]"* ]]
#}

@test "User adds a custom repository [vet-001]" {
  cd "$WORKSPACE"
  composer config repositories.notdesirable composer http://drupal.packagist.org
  git add . && git commit -m"$(basename "$0")" --quiet
  RESULT=$(vet)

  [[ "$RESULT" == *"[vet-001]"* ]]
}

@test "User turns off patching [vet-002]" {
  cd "$WORKSPACE"
  composer config extra.enable-patching false
  git add . && git commit -m"$(basename "$0")" --quiet

  RESULT=$(vet)

  [[ "$RESULT" == *"[vet-002]"* ]]
}

@test "User modifies composer scripts [vet-003]" {
  cd "$WORKSPACE"
  cat composer.json | jq '.scripts = "false"' > composer-new.json
  cp -f composer-new.json composer.json
  git add . && git commit -m"$(basename "$0")" --quiet

  RESULT=$(vet)
  echo "$RESULT"

  [[ "$RESULT" == *"[vet-003]"* ]]
}

@test "User alters the patches file reference [vet-004]" {
  cd "$WORKSPACE"
  composer config extra.patches-file "something-else"
  git add . && git commit -m"$(basename "$0")" --quiet

  RESULT=$(vet)

  [[ "$RESULT" == *"[vet-004]"* ]]
}

@test "User alters the patches.json [vet-005]" {
  cd "$WORKSPACE"
  touch custom/composer/patches.json
  echo '{"custom-patches": {"not": "desirable"}}' > custom/composer/patches.json
  git add . && git commit -m"$(basename "$0")" --quiet

  RESULT=$(vet)
  echo "$RESULT"

  [[ "$RESULT" == *"[vet-005]"* ]]
}

@test "User adds to or removes sections from custom composer.json [vet-006]" {
  cd "$WORKSPACE"
  touch custom/composer/composer.json
  echo '{"custom-keys": {"not": "desirable"}}' > custom/composer/composer.json
  git add . && git commit -m"$(basename "$0")" --quiet

  RESULT=$(vet)

  [[ "$RESULT" == *"[vet-006]"* ]]
}

@test "The user adds custom modules to the repo [vet-007]" {
  cp -Rf "$HERE"/drupal/modules "$WORKSPACE"/web/custom-modules-anywhere
  cd "$WORKSPACE"
  git add . && git commit -m"$(basename "$0")" --quiet

  RESULT=$(vet)

  [[ "$RESULT" == *"[vet-007]"* ]]
}

@test "Vet correct SaaS exit code" {
  cd "$WORKSPACE"
  composer config repositories.notdesirable composer http://drupal.packagist.org
  yq write -i .version.yml type saas
  git add . && git commit -m"$(basename "$0")" --quiet

  run vet
  [ "$status" -eq 1 ]

}

@test "Vet correct PaaS exit code" {
  cd "$WORKSPACE"
  composer config repositories.notdesirable composer http://drupal.packagist.org
  yq write -i .version.yml type paas
  git add . && git commit -m"$(basename "$0")" --quiet

  run vet
  [ "$status" -eq 0 ]
}
