<?php

/**
 * @file
 * Non-production settings. Included from settings.php.
 */

/**
 * Disable Google Analytics from sending dev GA data.
 */
$config['google_analytics.settings']['account'] = 'UA-XXXXXXXX-YY';

// Determine which cluster should be the production cluster for the
// stage_file_proxy url.
switch (getenv('GOVCMS_PROJECT_TYPE')) {
  case 'paas':
    $cluster = 'govcms6';
    break;

  default:
    $cluster = 'govcms5';
    break;
}

/**
 * Configure stage file proxy.
 */
if (getenv('STAGE_FILE_PROXY_URL')) {
  $config['stage_file_proxy.settings']['origin'] = getenv('STAGE_FILE_PROXY_URL');
}
elseif (getenv('LAGOON_PROJECT')) {
  $config['stage_file_proxy.settings']['origin'] = 'https://nginx-master-' . getenv('LAGOON_PROJECT') . ".{$cluster}.amazee.io";
}

/**
 * Configure Environment indicator.
 */
$config['environment_indicator.indicator']['bg_color'] = '#006600';
$config['environment_indicator.indicator']['fg_color'] = '#FFFFFF';
$config['environment_indicator.indicator']['name'] = 'Non-production';

// Stage file proxy does not copy all assets back to non-prods (eg. pdfs)
// this results in httpav attempting to scan a file that doesn't exist.
// to ensure that this use case is covered we should allow unchecked
// files.
$config['httpav.settings']['allow_unchecked'] = TRUE;
