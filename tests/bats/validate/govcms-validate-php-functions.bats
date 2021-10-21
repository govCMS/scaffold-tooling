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
  assert_output_contains "4      Should not use function \"shell_exec\", please change the code."
  assert_output_contains "6      Should not use function \"print_r\", please change the code."
}

@test "Check banned PHP functions: inc file" {
  export GOVCMS_SCAFFOLD_TOOLING_DIR=tests/bats/validate/fixtures/banned_functions
  export GOVCMS_RESULTS_STDOUT=1
  export GOVCMS_THEME_DIR=tests/bats/validate/fixtures/banned_functions/banned_functions.inc

  run scripts/validate/govcms-validate-php-functions >&3

  assert_output_contains "GovCMS Validate :: Banned PHP function list"
  assert_output_contains "4      Should not use function \"dd\", please change the code."
  assert_output_contains "6      Should not use function \"debug_backtrace\", please change the code."
}

@test "Check banned PHP functions: system functions" {
  export GOVCMS_SCAFFOLD_TOOLING_DIR=tests/bats/validate/fixtures/banned_functions
  export GOVCMS_RESULTS_STDOUT=1
  export GOVCMS_THEME_DIR=tests/bats/validate/fixtures/banned_functions/system_functions.php

  run scripts/validate/govcms-validate-php-functions >&3

  assert_output_contains "GovCMS Validate :: Banned PHP function list"
  assert_output_contains "4      Should not use function \"exec\", please change the code."
  assert_output_contains "6      Should not use function \"system\", please change the code."
  assert_output_contains "8      Should not use function \"shell_exec\", please change the code."
  assert_output_contains "10     Should not use function \"popen\", please change the code."

  assert_output_contains "12     Should not use function \"proc_open\", please change the code."
  assert_output_contains "14     Should not use function \"proc_get_status\", please change the code."
  assert_output_contains "16     Should not use function \"proc_terminate\", please change the code."
  assert_output_contains "18     Should not use function \"proc_close\", please change the code."
  assert_output_contains "20     Should not use function \"proc_nice\", please change the code."

  assert_output_contains "22     Should not use function \"passthru\", please change the code."
  assert_output_contains "24     Should not use function \"escapeshellcmd\", please change the code."
  assert_output_contains "27     Should not use node with type \"Expr_Eval\", please change the code."
}

@test "Check banned PHP functions: net functions" {
  export GOVCMS_SCAFFOLD_TOOLING_DIR=tests/bats/validate/fixtures/banned_functions
  export GOVCMS_RESULTS_STDOUT=1
  export GOVCMS_THEME_DIR=tests/bats/validate/fixtures/banned_functions/net_functions.php

  run scripts/validate/govcms-validate-php-functions >&3

  assert_output_contains "GovCMS Validate :: Banned PHP function list"
  assert_output_contains "5      Should not use function \"curl_exec\", please change the code."
  assert_output_contains "8      Should not use function \"curl_multi_exec\", please change the code."

  assert_output_contains "12     Should not use function \"ftp_connect\", please change the code."
  assert_output_contains "14     Should not use function \"ftp_exec\", please change the code."
  assert_output_contains "16     Should not use function \"ftp_get\", please change the code."
  assert_output_contains "18     Should not use function \"ftp_login\", please change the code."
  assert_output_contains "20     Should not use function \"ftp_nb_fput\", please change the code."
  assert_output_contains "22     Should not use function \"ftp_put\", please change the code."
  assert_output_contains "24     Should not use function \"ftp_raw\", please change the code."
  assert_output_contains "26     Should not use function \"ftp_rawlist\", please change the code."
}

@test "Check banned PHP functions: posix functions" {
  export GOVCMS_SCAFFOLD_TOOLING_DIR=tests/bats/validate/fixtures/banned_functions
  export GOVCMS_RESULTS_STDOUT=1
  export GOVCMS_THEME_DIR=tests/bats/validate/fixtures/banned_functions/posix_functions.php

  run scripts/validate/govcms-validate-php-functions >&3

  assert_output_contains "GovCMS Validate :: Banned PHP function list"

  assert_output_contains "4      Should not use function \"posix_getpwuid\", please change the code."
  assert_output_contains "6      Should not use function \"posix_kill\", please change the code."
  assert_output_contains "8      Should not use function \"posix_mkfifo\", please change the code."
  assert_output_contains "10     Should not use function \"posix_setpgid\", please change the code."
  assert_output_contains "12     Should not use function \"posix_setsid\", please change the code."
  assert_output_contains "14     Should not use function \"posix_setuid\", please change the code."
  assert_output_contains "16     Should not use function \"posix_uname\", please change the code."
}

@test "Check function not found" {
  export GOVCMS_SCAFFOLD_TOOLING_DIR=tests/bats/validate/fixtures/banned_functions
  export GOVCMS_RESULTS_STDOUT=1
  export GOVCMS_THEME_DIR=tests/bats/validate/fixtures/banned_functions/func_not_found.inc

  run scripts/validate/govcms-validate-php-functions >&3

  assert_output_not_contains "Function filter_formats not found"
  assert_output_not_contains "Function system_region_list not found"
}
