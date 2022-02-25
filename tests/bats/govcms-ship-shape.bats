#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2034,SC1087,SC2086

load _helpers_govcms

@test "Validate detection can find symlinks" {
  SCRIPT_DIR=tests/bats/fixtures/links
  FILES=$(find "$SCRIPT_DIR" -name "govcms-validate-*")

  i=0
  for file in $FILES; do
    ((i=i+1))
  done

  assert_equal 2 "$i"
  assert_equal "tests/bats/fixtures/links/govcms-validate-active-modules" $FILES[0]
}

@test "Validate detection can find proxies" {
  SCRIPT_DIR=tests/bats/fixtures/proxies
  FILES=$(find "$SCRIPT_DIR" -name "govcms-validate-*")

  i=0
  for file in $FILES; do
    ((i=i+1))
  done

  assert_equal 2 "$i"
  assert_equal "tests/bats/fixtures/proxies/govcms-validate-active-modules" $FILES[0]
}
