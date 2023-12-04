#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030

load ../_helpers_govcms

@test "Check banned PHP functions: defaults" {
  run scripts/validate/govcms-validate-php-functions >&3
  assert_output_contains "GovCMS Validate :: Banned PHP function list"
}

@test "Check banned PHP functions: theme file" {
  export GOVCMS_SCAFFOLD_TOOLING_DIR=tests/bats/validate/fixtures/banned_functions
  export GOVCMS_RESULTS_STDOUT=1
  export GOVCMS_THEME_DIR=tests/bats/validate/fixtures/banned_functions/banned_functions.theme

  run scripts/validate/govcms-validate-php-functions >&3

  assert_output_contains "GovCMS Validate :: Banned PHP function list"
  assert_output_contains "4      Calling shell_exec() is forbidden, please change the code"
  assert_output_contains "6      Calling print_r() is forbidden, please change the code"

  assert_output_contains "[ERROR] Found 2 errors"
}

@test "Check banned PHP classes and methods: theme file" {
  export GOVCMS_SCAFFOLD_TOOLING_DIR=tests/bats/validate/fixtures/banned_functions
  export GOVCMS_RESULTS_STDOUT=1
  export GOVCMS_THEME_DIR=tests/bats/validate/fixtures/banned_functions/banned_functions.theme
  export PHPSTAN_CONFIG=tests/bats/validate/fixtures/banned_functions/phpstan-extra.neon

  run scripts/validate/govcms-validate-php-functions >&3

  assert_output_contains "GovCMS Validate :: Banned PHP function list"
  assert_output_contains "8      Calling Drupal::httpClient() is forbidden, please change the code"
  assert_output_contains "10     Class GuzzleHttp\Client is forbidden, please change the code"

  assert_output_contains "[ERROR] Found 2 errors"
}

@test "Check banned PHP functions: inc file" {
  export GOVCMS_SCAFFOLD_TOOLING_DIR=tests/bats/validate/fixtures/banned_functions
  export GOVCMS_RESULTS_STDOUT=1
  export GOVCMS_THEME_DIR=tests/bats/validate/fixtures/banned_functions/banned_functions.inc

  run scripts/validate/govcms-validate-php-functions >&3

  assert_output_contains "GovCMS Validate :: Banned PHP function list"
  assert_output_contains "4      Calling dd() is forbidden, please change the code"
  assert_output_contains "6      Calling debug_backtrace() is forbidden, please change the code"
  assert_output_contains "8      Calling mysqli::__construct() is forbidden, please change the code [mysqli::__construct() matches mysqli::*()]"
  assert_output_contains "9      Calling mysqli::close() is forbidden, please change the code [mysqli::close() matches mysqli::*()]"

  assert_output_contains "[ERROR] Found 4 errors"
}

@test "Check banned PHP functions: system functions" {
  export GOVCMS_SCAFFOLD_TOOLING_DIR=tests/bats/validate/fixtures/banned_functions
  export GOVCMS_RESULTS_STDOUT=1
  export GOVCMS_THEME_DIR=tests/bats/validate/fixtures/banned_functions/system_functions.php

  run scripts/validate/govcms-validate-php-functions >&3

  assert_output_contains "GovCMS Validate :: Banned PHP function list"
  assert_output_contains "4      Calling exec() is forbidden, please change the code"
  assert_output_contains "6      Calling system() is forbidden, please change the code"
  assert_output_contains "8      Calling shell_exec() is forbidden, please change the code"
  assert_output_contains "10     Calling popen() is forbidden, please change the code"

  assert_output_contains "12     Calling proc_open() is forbidden, please change the code"
  assert_output_contains "14     Calling proc_get_status() is forbidden, please change the code"
  assert_output_contains "16     Calling proc_terminate() is forbidden, please change the code"
  assert_output_contains "18     Calling proc_close() is forbidden, please change the code"
  assert_output_contains "20     Calling proc_nice() is forbidden, please change the code"

  assert_output_contains "22     Calling passthru() is forbidden, please change the code"
  assert_output_contains "24     Calling escapeshellcmd() is forbidden, please change the code"
  assert_output_contains "27     Calling eval() is forbidden, please change the code"

  assert_output_contains "[ERROR] Found 12 errors"
}

@test "Check banned PHP functions: net functions" {
  export GOVCMS_SCAFFOLD_TOOLING_DIR=tests/bats/validate/fixtures/banned_functions
  export GOVCMS_RESULTS_STDOUT=1
  export GOVCMS_THEME_DIR=tests/bats/validate/fixtures/banned_functions/net_functions.php

  run scripts/validate/govcms-validate-php-functions >&3

  assert_output_contains "GovCMS Validate :: Banned PHP function list"
  assert_output_contains "6      Calling curl_init() is forbidden, please change the code"
  assert_output_contains "7      Calling curl_exec() is forbidden, please change the code"
  assert_output_contains "10     Calling curl_multi_exec() is forbidden, please change the code"

  assert_output_contains "14     Calling ftp_connect() is forbidden, please change the code"
  assert_output_contains "16     Calling ftp_exec() is forbidden, please change the code"
  assert_output_contains "18     Calling ftp_get() is forbidden, please change the code"
  assert_output_contains "20     Calling ftp_login() is forbidden, please change the code"
  assert_output_contains "22     Calling ftp_nb_fput() is forbidden, please change the code"
  assert_output_contains "24     Calling ftp_put() is forbidden, please change the code"
  assert_output_contains "26     Calling ftp_raw() is forbidden, please change the code"
  assert_output_contains "28     Calling ftp_rawlist() is forbidden, please change the code"

  assert_output_contains "[ERROR] Found 11 errors"
}

@test "Check banned PHP functions: net functions namespace" {
  export GOVCMS_SCAFFOLD_TOOLING_DIR=tests/bats/validate/fixtures/banned_functions
  export GOVCMS_RESULTS_STDOUT=1
  export GOVCMS_THEME_DIR=tests/bats/validate/fixtures/banned_functions/net_functions.php
  export PHPSTAN_CONFIG=tests/bats/validate/fixtures/banned_functions/phpstan-extra.neon

  run scripts/validate/govcms-validate-php-functions >&3

  assert_output_contains "GovCMS Validate :: Banned PHP function list"
  assert_output_contains "3      Namespace GuzzleHttp\Client is forbidden, please change the code"

  assert_output_contains "[ERROR] Found 1 error"
}

@test "Check banned PHP functions: posix functions" {
  export GOVCMS_SCAFFOLD_TOOLING_DIR=tests/bats/validate/fixtures/banned_functions
  export GOVCMS_RESULTS_STDOUT=1
  export GOVCMS_THEME_DIR=tests/bats/validate/fixtures/banned_functions/posix_functions.php

  run scripts/validate/govcms-validate-php-functions >&3

  assert_output_contains "GovCMS Validate :: Banned PHP function list"

  assert_output_contains "4      Calling posix_getpwuid() is forbidden, please change the code"
  assert_output_contains "6      Calling posix_kill() is forbidden, please change the code"
  assert_output_contains "8      Calling posix_mkfifo() is forbidden, please change the code"
  assert_output_contains "10     Calling posix_setpgid() is forbidden, please change the code"
  assert_output_contains "12     Calling posix_setsid() is forbidden, please change the code"
  assert_output_contains "14     Calling posix_setuid() is forbidden, please change the code"
  assert_output_contains "16     Calling posix_uname() is forbidden, please change the code"

  assert_output_contains "[ERROR] Found 7 errors"
}

@test "Check function not found" {
  export GOVCMS_SCAFFOLD_TOOLING_DIR=tests/bats/validate/fixtures/banned_functions
  export GOVCMS_RESULTS_STDOUT=1
  export GOVCMS_THEME_DIR=tests/bats/validate/fixtures/banned_functions/func_not_found.inc

  run scripts/validate/govcms-validate-php-functions >&3

  assert_output_not_contains "Function filter_formats not found"
  assert_output_not_contains "Function system_region_list not found"

  assert_success
}

@test "Assert valid function file" {
  export GOVCMS_SCAFFOLD_TOOLING_DIR=tests/bats/validate/fixtures/banned_functions
  export GOVCMS_RESULTS_STDOUT=1
  export GOVCMS_THEME_DIR=tests/bats/validate/fixtures/banned_functions/valid_file.inc

  run scripts/validate/govcms-validate-php-functions >&3

  assert_success
}
