#!/usr/bin/env php
<?php

// Test contexts.
$http_host = getenv('HTTP_HOST') ?: 'test.gov.au';
$installation_attempted = getenv('INSTALLATION_ATTEMPTED') ?: FALSE;

// Mock Drupal.
$settings = [];
$config = [];
$databases = [];

// Not testing for the dynamic inclusion of projects.settings.php and local
// settings.
$app_root = 'not-applicable';
// @todo: Remove in Drupal 9.
define('CONFIG_SYNC_DIRECTORY', 'sync');
$_SERVER['HTTP_HOST'] = $http_host;
if ($installation_attempted) {
  function drupal_installation_attempted() {
    return TRUE;
  }
}
else {
  function drupal_installation_attempted() {
    return FALSE;
  }
}

// This variable is the run-time optional way to point to an alternative location of https://github.com/govCMS/scaffold-tooling/tree/develop/drupal/settings
putenv('GOVCMS_DRUPAL_SETTINGS=./drupal/settings');

// Copy of settings.php from scaffold placed during bats `setup`
$scaffold_settings_dot_php = '/tmp/bats/settings.php';
if (!file_exists($scaffold_settings_dot_php)) {
  echo 'See drupal-settings.bats setup() for how download and setup ' . $scaffold_settings_dot_php;
}

// Simulate settings load in Drupal.
require $scaffold_settings_dot_php;

// Output as Json (can parse output with jq).
$output = [
  'settings' => $settings,
  'config' => $config,
  'databases' => $databases,
  'included_files' => [],
];
foreach (get_included_files() as $file) {
  $output['included_files'][basename($file)] = $file;
}
print json_encode($output);
