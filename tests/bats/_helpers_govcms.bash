#!/usr/bin/env bash
##
# GovCMS Bats test helpers.
#
# Include this file into every test file to access utilities and assertions.
#
# shellcheck disable=SC2119,SC2120,SC2034,SC2155

load "${BASH_SOURCE[0]%/*}"/_helpers.bash
load "${BASH_SOURCE[0]%/*}"/_bats-mock.bash

# Test setup. Runs before every test.
# This is a generic setup for all tests. To override it in specific tests,
# implement setup() and call the same methods as in the code below (there is
# no inheritance in Bash, so we cannot just extend parent setup()).
setup() {
  CUR_DIR="$PWD"

  export TEST_APP_DIR=$(prepare_app_dir)
  setup_mock
}

# Prepare application directory to be used in tests.
prepare_app_dir(){
  APP_DIR="$BATS_TEST_TMPDIR/app"
  rm -Rf "$APP_DIR" >/dev/null
  mkdir -p "$APP_DIR"
  echo "$APP_DIR"
}

# Setup mock support.
# Call this function from your test's setup() method.
setup_mock(){
  # Command and functions mocking support.
  # @see https://github.com/grayhemp/bats-mock
  #
  # Prepare directory with mock binaries, get it's path, and export it so that
  # bats-mock could use it internally.
  BATS_MOCK_TMPDIR="$(mock_prepare_tmp)"
  export "BATS_MOCK_TMPDIR"
  # Set the path to temp mocked binaries directory as the first location in
  # PATH to lookup in mock directories first. This change lives only for the
  # duration of the test and will be reset after. It does not modify the PATH
  # outside of the running test.
  PATH="${BATS_MOCK_TMPDIR}:$PATH"
}

# Prepare temporary mock directory.
mock_prepare_tmp(){
  rm -rf "${BATS_TMPDIR}/bats-mock-tmp" >/dev/null
  mkdir -p "${BATS_TMPDIR}/bats-mock-tmp"
  echo "${BATS_TMPDIR}/bats-mock-tmp"
}

# Mock provided command.
# Arguments:
#  1. Mocked command name,
# Outputs:
#   STDOUT: path to created mock file.
mock_command(){
  mocked_command="${1}"
  mock="$(mock_create)"
  mock_path="${mock%/*}"
  mock_file="${mock##*/}"
  ln -sf "${mock_path}/${mock_file}" "${mock_path}/${mocked_command}"
  echo "$mock"
}

fixture_config(){
  local dir="${1?'App directory must be specified'}"
  local count="${2?'Number of config files must be specified'}"

  while [  "$count" -gt 0 ]; do
    mktouch "$dir/config$count.yml"
    count=$(( count - 1 ))
  done
}
