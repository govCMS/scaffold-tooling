<?php

/**
 * @file
 * Production settings. Included from settings.php.
 */

// phpcs:ignore DrupalPractice.CodeAnalysis.VariableAnalysis.UndefinedVariable

// See comment in all.settings.php.
// phpcs:ignore DrupalPractice.CodeAnalysis.VariableAnalysis.UndefinedVariable
$govcms_includes = isset($govcms_includes) ? $govcms_includes : __DIR__;

/**
 * Include the corresponding *.services.yml.
 */
// phpcs:ignore DrupalPractice.CodeAnalysis.VariableAnalysis.UndefinedVariable
$settings['container_yamls'][] = $govcms_includes . '/production.services.yml';

// Inject Google Analytics snippet on all production sites.
$config['google_analytics.settings']['codesnippet']['after'] = "gtag('config', 'UA-54970022-1', {'name': 'govcms'}); gtag('govcms.send', 'pageview', {'anonymizeIp': true})";

// Don't show any error messages on the site (will still be shown in watchdog).
$config['system.logging']['error_level'] = 'hide';

// Set max cache lifetime to 15m by default.
$config['system.performance']['cache']['page']['max_age'] = 900;
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
