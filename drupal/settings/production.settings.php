<?php

/**
 * @file
 * Production settings. Included from settings.php.
 */

// phpcs:ignore DrupalPractice.CodeAnalysis.VariableAnalysis.UndefinedVariable

// See comment in all.settings.php.
// phpcs:ignore DrupalPractice.CodeAnalysis.VariableAnalysis.UndefinedVariable
$govcms_includes = $govcms_includes ?? __DIR__;

/**
 * Include the corresponding *.services.yml.
 */
// phpcs:ignore DrupalPractice.CodeAnalysis.VariableAnalysis.UndefinedVariable
$settings['container_yamls'][] = $govcms_includes . '/production.services.yml';

// Inject Google Analytics snippet on all production sites.
$config['google_analytics.settings']['codesnippet']['after'] = "gtag('config', 'G-0XT7NFV9ZS', {'name': 'govcms'}); gtag('govcms.send', 'pageview', {'anonymizeIp': true})";

// Don't show any error messages on the site (will still be shown in watchdog).
$config['system.logging']['error_level'] = 'hide';

// Set max cache lifetime to 1 week by default.
$config['system.performance']['cache']['page']['max_age'] = 604800;
if (is_numeric($max_age = getenv('CACHE_MAX_AGE'))) {
  $config['system.performance']['cache']['page']['max_age'] = $max_age;
}

// Aggregate CSS files on.
$config['system.performance']['css']['preprocess'] = 1;

// Aggregate JavaScript files on.
$config['system.performance']['js']['preprocess'] = 1;

// Disabling stage file proxy on production, with that the module can be enabled
// even on production.
$config['stage_file_proxy.settings']['origin'] = FALSE;

// Configure Environment indicator.
$config['environment_indicator.indicator']['bg_color'] = '#AF110E';
$config['environment_indicator.indicator']['fg_color'] = '#FFFFFF';
$config['environment_indicator.indicator']['name'] = 'Production';

// Disable temporary file deletion (GOVCMSD8-576).
$config['system.file']['temporary_maximum_age'] = 0;
if (is_numeric($file_gc = getenv('GOVCMS_FILE_TEMP_MAX_AGE'))) {
  $config['system.file']['temporary_maximum_age'] = $file_gc;
}

$config['lagoon_logs.settings']['host'] = getenv('LAGOON_LOGS_ENDPOINT') ?: 'application-logs.lagoon.svc';
$config['lagoon_logs.settings']['port'] = 5140;
$config['lagoon_logs.settings']['identifier'] = 'drupal';
$config['lagoon_logs.settings']['disable'] = 0;

/**
 * Security.txt settings.
 */
// Security.txt must be enabled.
$config['securitytxt.settings']['enabled'] = TRUE;

// Enforce TFA.
if (!empty(getenv('GOVCMS_TFA_ENFORCE'))) {
  $config['tfa.settings']['enabled'] = TRUE;
  if (empty(getenv('GOVCMS_TFA_DISABLE_REQUIRED_ROLES'))) {
    $config['tfa.settings']['required_roles']['authenticated'] = 'authenticated';
    $config['user.role.authenticated']['permissions'][999999] = 'setup own tfa';
  }
  // GOVCMS-10498 - Disable tfa_trusted_browser plugin.
  if (empty(getenv('GOVCMS_TFA_ALLOW_TRUSTED_BROWSER'))) {
    // As tfa_trusted_browser is the only login plugin shipped in TFA,
    // we can override the login_plugins key with NULL.
    // Setting it to an empty array [] or overriding individual array key
    // will not work.
    // @see https://git.drupalcode.org/project/tfa/-/blob/8.x-1.x/src/TfaLoginPluginManager.php?ref_type=heads#L120
    // @see \Drupal\tfa\TfaLoginPluginManager::getPlugins()
    // @see https://git.drupalcode.org/project/tfa/-/blob/2.x/src/TfaPluginManager.php?ref_type=heads#L117
    // @see \Drupal\tfa\TfaPluginManager::getClassDefinitions()
    // In the future, if TFA includes more useful login plugins
    // which are allowed on the platform, this approach will need
    // to be reworked.
    $config['tfa.settings']['login_plugins'] = NULL;
  }
}

// Enforce password policy for all users.
$config['password_policy.password_policy.austism']['roles']['authenticated'] = 'authenticated';
