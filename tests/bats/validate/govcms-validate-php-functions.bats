#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030

load ../_helpers_govcms

@test "Check banned PHP functions: defaults" {
  run scripts/validate/govcms-validate-php-functions >&3
  assert_output_contains "GovCMS Validate :: Banned PHP function list"
}

@test "Check banned PHP functions: theme file" {
  export GOVCMS_RESULTS_STDOUT=1
  export GOVCMS_THEME_DIR=tests/bats/validate/fixtures/banned_functions/banned_functions.theme

  run scripts/validate/govcms-validate-php-functions >&3

  assert_output_contains "GovCMS Validate :: Banned PHP function list"
  assert_output_contains "banned_functions.theme:4:Should not use function \"shell_exec\", please change the code."
  assert_output_contains "banned_functions.theme:6:Should not use function \"print_r\", please change the code."
}

@test "Check banned PHP functions: inc file" {
  export GOVCMS_RESULTS_STDOUT=1
  export GOVCMS_THEME_DIR=tests/bats/validate/fixtures/banned_functions/banned_functions.inc

  run scripts/validate/govcms-validate-php-functions >&3

  assert_output_contains "GovCMS Validate :: Banned PHP function list"
  assert_output_contains "banned_functions.inc:4:Should not use function \"dd\", please change the code."
  assert_output_contains "banned_functions.inc:6:Should not use function \"debug_backtrace\", please change the code."
}

@test "Check banned PHP functions: system functions" {
  export GOVCMS_RESULTS_STDOUT=1
  export GOVCMS_THEME_DIR=tests/bats/validate/fixtures/banned_functions/system_functions.php

  run scripts/validate/govcms-validate-php-functions >&3

  assert_output_contains "GovCMS Validate :: Banned PHP function list"
  assert_output_contains "system_functions.php:4:Should not use function \"exec\", please change the code."
  assert_output_contains "system_functions.php:6:Should not use function \"system\", please change the code."
  assert_output_contains "system_functions.php:8:Should not use function \"shell_exec\", please change the code."
  assert_output_contains "system_functions.php:10:Should not use function \"popen\", please change the code."

  assert_output_contains "system_functions.php:12:Should not use function \"proc_open\", please change the code."
  assert_output_contains "system_functions.php:14:Should not use function \"proc_get_status\", please change the code."
  assert_output_contains "system_functions.php:16:Should not use function \"proc_terminate\", please change the code."
  assert_output_contains "system_functions.php:18:Should not use function \"proc_close\", please change the code."
  assert_output_contains "system_functions.php:20:Should not use function \"proc_nice\", please change the code."

  assert_output_contains "system_functions.php:22:Should not use function \"passthru\", please change the code."
  assert_output_contains "system_functions.php:24:Should not use function \"escapeshellcmd\", please change the code."
  assert_output_contains "system_functions.php:27:Should not use node with type \"Expr_Eval\", please change the code."
}

@test "Check banned PHP functions: net functions" {
  export GOVCMS_RESULTS_STDOUT=1
  export GOVCMS_THEME_DIR=tests/bats/validate/fixtures/banned_functions/net_functions.php

  run scripts/validate/govcms-validate-php-functions >&3

  assert_output_contains "GovCMS Validate :: Banned PHP function list"
  assert_output_contains "net_functions.php:5:Should not use function \"curl_exec\", please change the code."
  assert_output_contains "net_functions.php:8:Should not use function \"curl_multi_exec\", please change the code."

  assert_output_contains "net_functions.php:12:Should not use function \"ftp_connect\", please change the code."
  assert_output_contains "net_functions.php:14:Should not use function \"ftp_exec\", please change the code."
  assert_output_contains "net_functions.php:16:Should not use function \"ftp_get\", please change the code."
  assert_output_contains "net_functions.php:18:Should not use function \"ftp_login\", please change the code."
  assert_output_contains "net_functions.php:20:Should not use function \"ftp_nb_fput\", please change the code."
  assert_output_contains "net_functions.php:22:Should not use function \"ftp_put\", please change the code."
  assert_output_contains "net_functions.php:24:Should not use function \"ftp_raw\", please change the code."
  assert_output_contains "net_functions.php:26:Should not use function \"ftp_rawlist\", please change the code."
}

@test "Check banned PHP functions: posix functions" {
  export GOVCMS_RESULTS_STDOUT=1
  export GOVCMS_THEME_DIR=tests/bats/validate/fixtures/banned_functions/posix_functions.php

  run scripts/validate/govcms-validate-php-functions >&3

  assert_output_contains "GovCMS Validate :: Banned PHP function list"

  assert_output_contains "posix_functions.php:4:Should not use function \"posix_getpwuid\", please change the code."
  assert_output_contains "posix_functions.php:6:Should not use function \"posix_kill\", please change the code."
  assert_output_contains "posix_functions.php:8:Should not use function \"posix_mkfifo\", please change the code."
  assert_output_contains "posix_functions.php:10:Should not use function \"posix_setpgid\", please change the code."
  assert_output_contains "posix_functions.php:12:Should not use function \"posix_setsid\", please change the code."
  assert_output_contains "posix_functions.php:14:Should not use function \"posix_setuid\", please change the code."
  assert_output_contains "posix_functions.php:16:Should not use function \"posix_uname\", please change the code."
}
