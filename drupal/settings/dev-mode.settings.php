<?php

/**
 * @file
 * DEV_MODE specific settings. Included from settings.php.
 */

// Cookie handling to allow HTTP requests as modern browsers may try to
// upgrade the request and require the cookie to be "Secure" if samesite
// is "None" (default).
ini_set('session.cookie_samesite', 'Lax');

// See comment in all.settings.php.
// phpcs:ignore DrupalPractice.CodeAnalysis.VariableAnalysis.UndefinedVariable
$govcms_includes = $govcms_includes ?? __DIR__;

/**
 * Include the corresponding *.services.yml.
 */
// phpcs:ignore DrupalPractice.CodeAnalysis.VariableAnalysis.UndefinedVariable
$settings['container_yamls'][] = $govcms_includes . '/development.services.yml';

/**
 * Show all error messages, with backtrace information.
 *
 * In case the error level could not be fetched from the database, as for
 * example the database connection failed, we rely only on this value.
 */
$config['system.logging']['error_level'] = 'verbose';

/**
 * Set expiration of cached pages to 0.
 */
$config['system.performance']['cache']['page']['max_age'] = 0;

/**
 * Disable CSS and JS aggregation.
 */
$config['system.performance']['css']['preprocess'] = FALSE;
$config['system.performance']['js']['preprocess'] = FALSE;

/**
 * Disable render caches for twig files to be reloaded on every page view.
 */
$settings['cache']['bins']['render'] = 'cache.backend.null';
$settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.null';
