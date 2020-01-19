<?php

/**
 * @file
 * Lagoon Drupal 8 configuration file.
 *
 * This file will only run if a lagoon environment is detected (local or on
 * the platform.).
 */

// Corresponding services.yml.
// phpcs:ignore DrupalPractice.CodeAnalysis.VariableAnalysis.UndefinedVariable
$settings['container_yamls'][] = $govcms_settings . '/lagoon.services.yml';

// Configuration path settings.
$config_directories[CONFIG_SYNC_DIRECTORY] = '/app/config/default';
$config_directories['dev'] = '/app/config/dev';

$databases['default']['default'] = [
  'driver' => 'mysql',
  'database' => getenv('MARIADB_DATABASE') ?: 'drupal',
  'username' => getenv('MARIADB_USERNAME') ?: 'drupal',
  'password' => getenv('MARIADB_PASSWORD') ?: 'drupal',
  'host' => getenv('MARIADB_HOST') ?: 'mariadb',
  'port' => 3306,
  'charset' => 'utf8mb4',
  'collation' => 'utf8mb4_general_ci',
];

// Lagoon Solr connection.
$config['search_api.server']['backend_config']['connector_config']['host'] = getenv('SOLR_HOST') ?: 'solr';
$config['search_api.server']['backend_config']['connector_config']['path'] = '/solr/' . getenv('SOLR_CORE') ?: 'drupal';

// Lagoon Varnish & reverse proxy settings.
$varnish_control_port = getenv('VARNISH_CONTROL_PORT') ?: '6082';
$varnish_hosts = explode(',', getenv('VARNISH_HOSTS') ?: 'varnish');
array_walk($varnish_hosts, function (&$value, $key) use ($varnish_control_port) {
  $value .= ":$varnish_control_port";
});

$settings['reverse_proxy'] = TRUE;
$settings['reverse_proxy_addresses'] = array_merge(explode(',', getenv('VARNISH_HOSTS')), ['varnish']);
$settings['varnish_control_terminal'] = implode($varnish_hosts, " ");
$settings['varnish_control_key'] = getenv('VARNISH_SECRET') ?: 'lagoon_default_secret';
$settings['varnish_version'] = 4;

// Redis configuration.
if (getenv('ENABLE_REDIS')) {
  $settings['redis.connection']['interface'] = 'PhpRedis';
  $settings['redis.connection']['host'] = getenv('REDIS_HOST') ?: 'redis';
  $settings['redis.connection']['port'] = 6379;

  $settings['cache_prefix']['default'] = getenv('LAGOON_PROJECT') . '_' . getenv('LAGOON_GIT_SAFE_BRANCH');

  // Do not set the cache during installations of Drupal.
  if (!drupal_installation_attempted()) {
    $settings['cache']['default'] = 'cache.backend.redis';

    // Include the default example.services.yml from the module, which will
    // replace all supported backend services (that currently includes the cache
    // tags checksum service and the lock backends, check the file for the
    // current list).
    $settings['container_yamls'][] = 'modules/contrib/redis/example.services.yml';

    // Allow the services to work before the Redis module itself is enabled.
    $settings['container_yamls'][] = 'modules/contrib/redis/redis.services.yml';

    // Manually add the classloader path, this is required for the container
    // cache bin definition below and allows to use it without the redis module
    // being enabled.
    // @see https://github.com/govCMS/scaffold-tooling/issues/30
    // phpcs:ignore Drupal.NamingConventions.ValidGlobal.GlobalUnderScore
    global $class_loader;
    $class_loader->addPsr4('Drupal\\redis\\', 'modules/contrib/redis/src');

    // Use redis for container cache.
    // The container cache is used to load the container definition itself, and
    // thus any configuration stored in the container itself is not available
    // yet. These lines force the container cache to use Redis rather than the
    // default SQL cache.
    $settings['bootstrap_container_definition'] = [
      'parameters' => [],
      'services' => [
        'redis.factory' => [
          'class' => 'Drupal\redis\ClientFactory',
        ],
        'cache.backend.redis' => [
          'class' => 'Drupal\redis\Cache\CacheBackendFactory',
          'arguments' => [
            '@redis.factory',
            '@cache_tags_provider.container',
            '@serialization.phpserialize',
          ],
        ],
        'cache.container' => [
          'class' => '\Drupal\redis\Cache\PhpRedis',
          'factory' => ['@cache.backend.redis', 'get'],
          'arguments' => ['container'],
        ],
        'cache_tags_provider.container' => [
          'class' => 'Drupal\redis\Cache\RedisCacheTagsChecksum',
          'arguments' => ['@redis.factory'],
        ],
        'serialization.phpserialize' => [
          'class' => 'Drupal\Component\Serialization\PhpSerialize',
        ],
      ],
    ];
  }
}

// ClamAV settings.
$config['clamav.settings']['scan_mode'] = 1;
$config['clamav.settings']['mode_executable']['executable_path'] = '/usr/bin/clamscan';

// Hash Salt.
$settings['hash_salt'] = hash('sha256', getenv('LAGOON_PROJECT'));
