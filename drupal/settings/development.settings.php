<?php

/**
 * @file
 * Non-production settings. Included from settings.php.
 */

/**
 * Include development services yml.
 */
$settings['container_yamls'][] = DRUPAL_ROOT . '/sites/default/development.services.yml';

/**
 * Disable Google Analytics from sending dev GA data.
 */
$config['google_analytics.settings']['account'] = 'UA-XXXXXXXX-YY';

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
