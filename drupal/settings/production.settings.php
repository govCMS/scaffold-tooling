<?php

/**
 * @file
 * Production settings. Included from settings.php.
 */

/**
 * Include production.services.yml.
 */

// Corresponding services.yml.
// phpcs:ignore DrupalPractice.CodeAnalysis.VariableAnalysis.UndefinedVariable
$settings['container_yamls'][] = $govcms_settings . '/production.services.yml';

// Inject Google Analytics snippet on all production sites.
$config['google_analytics.settings']['codesnippet']['after'] = "gtag('config', 'UA-54970022-1', {'name': 'govcms'}); gtag('govcms.send', 'pageview', {'anonymizeIp': true})";

// Don't show any error messages on the site (will still be shown in watchdog).
$config['system.logging']['error_level'] = 'hide';

// Set max cache lifetime to 15m by default.
$config['system.performance']['cache']['page']['max_age'] = 900;
if (is_numeric($max_age=GETENV('CACHE_MAX_AGE'))) {
  $config['system.performance']['cache']['page']['max_age'] = $max_age;
}

// Aggregate CSS files on.
$config['system.performance']['css']['preprocess'] = 1;

// Aggregate JavaScript files on.
$config['system.performance']['js']['preprocess'] = 1;

// Disabling stage file proxy on production, with that the module can be enabled
// even on production.
$config['stage_file_proxy.settings']['origin'] = FALSE;
