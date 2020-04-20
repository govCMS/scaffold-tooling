#!/usr/bin/env bats
# shellcheck disable=SC2002

load _helpers_govcms

setup() {
  CUR_DIR="$PWD"
  WORKSPACE="$BATS_TMPDIR/scaffold"

  if [ ! -d "$WORKSPACE/.git" ]; then
    rm -Rf "$WORKSPACE"
    git clone https://github.com/govCMS/govcms8-scaffold-paas "$WORKSPACE"
    cd "$WORKSPACE" || exit
    git tag -f rollback
    git config user.email "noone@example.gov.au"
    git config user.name "Falcor"
  fi

  cd "$WORKSPACE" || exit
  git --version
  git reset --hard --quiet rollback
  git clean -fd --quiet
}

vet() {
  "$CUR_DIR"/scripts/govcms-vet
}

@test "User adds a custom repository [vet-001]" {
  composer config repositories.notdesirable composer http://drupal.packagist.org
  git add . && git commit -m"$(basename "$0")" --quiet
  RESULT=$(vet)

  [[ "$RESULT" == *"[vet-001]"* ]]
}

@test "User turns off patching [vet-002]" {
  composer config extra.enable-patching false
  git add . && git commit -m"$(basename "$0")" --quiet

  RESULT=$(vet)

  [[ "$RESULT" == *"[vet-002]"* ]]
}

@test "User modifies composer scripts [vet-003]" {
  cat composer.json | jq '.scripts = "false"' > composer-new.json
  cp -f composer-new.json composer.json
  git add . && git commit -m"$(basename "$0")" --quiet

  RESULT=$(vet)
  echo "$RESULT"

  [[ "$RESULT" == *"[vet-003]"* ]]
}

@test "User alters the patches file reference [vet-004]" {
  composer config extra.patches-file "something-else"
  git add . && git commit -m"$(basename "$0")" --quiet

  RESULT=$(vet)

  [[ "$RESULT" == *"[vet-004]"* ]]
}

@test "User alters the patches.json [vet-005]" {
  touch custom/composer/patches.json
  echo '{"custom-patches": {"not": "desirable"}}' > custom/composer/patches.json
  git add . && git commit -m"$(basename "$0")" --quiet

  RESULT=$(vet)
  echo "$RESULT"

  [[ "$RESULT" == *"[vet-005]"* ]]
}

@test "User adds to or removes sections from custom composer.json [vet-006]" {
  touch custom/composer/composer.json
  echo '{"custom-keys": {"not": "desirable"}}' > custom/composer/composer.json
  git add . && git commit -m"$(basename "$0")" --quiet

  RESULT=$(vet)

  [[ "$RESULT" == *"[vet-006]"* ]]
}

@test "The user adds custom modules to the repo [vet-007]" {
  cp -Rf "$CUR_DIR"/drupal/modules "$WORKSPACE"/web/custom-modules-anywhere
  git add . && git commit -m"$(basename "$0")" --quiet

  RESULT=$(vet)

  [[ "$RESULT" == *"[vet-007]"* ]]
}

@test "Vet correct SaaS exit code" {
  composer config repositories.notdesirable composer http://drupal.packagist.org
  yq write -i .version.yml type saas
  git add . && git commit -m"$(basename "$0")" --quiet

  run vet
  [ "$status" -eq 1 ]
}

@test "Vet correct PaaS exit code" {
  composer config repositories.notdesirable composer http://drupal.packagist.org
  yq write -i .version.yml type paas
  git add . && git commit -m"$(basename "$0")" --quiet

  run vet
  [ "$status" -eq 0 ]
}
