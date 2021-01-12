<?php

/**
 * @file
 * Non-production settings. Included from settings.php.
 */

/**
 * Include development services yml.
 */

// See comment in all.settings.php.
// phpcs:ignore DrupalPractice.CodeAnalysis.VariableAnalysis.UndefinedVariable
$govcms_includes = isset($govcms_includes) ? $govcms_includes : __DIR__;

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
 * Disable Google Analytics from sending dev GA data.
 */
$config['google_analytics.settings']['account'] = 'UA-XXXXXXXX-YY';

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

/**
 * Configure stage file proxy.
 */
if (getenv('STAGE_FILE_PROXY_URL')) {
  $config['stage_file_proxy.settings']['origin'] = getenv('STAGE_FILE_PROXY_URL');
}
elseif (getenv('LAGOON_PROJECT')) {
  $config['stage_file_proxy.settings']['origin'] = 'https://nginx-' . getenv('LAGOON_PROJECT') . '-master.govcms.amazee.io';
}

/**
 * Configure Environment indicator.
 */
$config['environment_indicator.indicator']['bg_color'] = '#006600';
$config['environment_indicator.indicator']['fg_color'] = '#FFFFFF';
$config['environment_indicator.indicator']['name'] = 'Non-production';
