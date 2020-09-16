<?php

/**
 * @file
 * Lagoon Drupal 8 configuration file.
 *
 * This file will only run if a lagoon environment is detected (local or on
 * the platform.).
 */

// See comment in all.settings.php.
// phpcs:ignore DrupalPractice.CodeAnalysis.VariableAnalysis.UndefinedVariable
$govcms_includes = isset($govcms_includes) ? $govcms_includes : __DIR__;

/**
 * Include the corresponding *.services.yml.
 */
// phpcs:ignore DrupalPractice.CodeAnalysis.VariableAnalysis.UndefinedVariable
$settings['container_yamls'][] = $govcms_includes . '/lagoon.services.yml';

$db_conf = [
  'driver' => 'mysql',
  'database' => getenv('MARIADB_DATABASE') ?: 'drupal',
  'username' => getenv('MARIADB_USERNAME') ?: 'drupal',
  'password' => getenv('MARIADB_PASSWORD') ?: 'drupal',
  'port' => 3306,
  'charset' => 'utf8mb4',
  'collation' => 'utf8mb4_general_ci',
];

$databases['default']['default'] = array_merge($db_conf, [
  'host' => getenv('MARIADB_HOST') ?: 'mariadb',
]);

if (getenv('MARIADB_READREPLICA_HOSTS')) {
  $replica_hosts = explode(' ', getenv('MARIADB_READREPLICA_HOSTS'));
  $replica_hosts = array_map('trim', $replica_hosts);

  if (!empty($replica_hosts)) {
    // Add a standalone connection to the read replica. This allows Drush to
    // target the readers directly with --database=read.
    $databases['read']['default'] = array_merge($db_conf, [
      'host' => $replica_hosts[0],
    ]);

    foreach ($replica_hosts as $replica_host) {
      // Add replica support to the default database connection. This allows
      // services to use the database.replica service for particular operations.
      // @TODO: Lagoon should expose MARAIDB replica hosts as an array so we can
      // scale the replicas horizontally.
      $databases['default']['replica'][] = array_merge($db_conf, [
        'host' => $replica_host,
      ]);
    }
  }
}

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
  $redis = new \Redis();
  $redis_host = getenv('REDIS_HOST') ?: 'redis';
  $redis_port = getenv('REDIS_PORT') ?: 6379;
  // Redis should return in < 1s so this is a maximum time
  // to ensure we don't hold the proc forever.
  $redis_timeout = getenv('REDIS_CONNECT_TIMEOUT') ?: 2;

  try {
    if (drupal_installation_attempted()) {
      // Do not set the cache during installations of Drupal.
      throw new \Exception('Drupal installation underway.');
    }

    $redis->connect($redis_host, $redis_port, $redis_timeout);
    $response = $redis->ping();
    if (strpos($response, 'PONG') === FALSE) {
      throw new \Exception('Redis could be reached but is not responding correctly.');
    }

    $settings['redis.connection']['interface'] = 'PhpRedis';
    $settings['redis.connection']['host'] = $redis_host;
    $settings['redis.connection']['port'] = $redis_port;
    $settings['cache_prefix']['default'] = getenv('LAGOON_PROJECT') . '_' . getenv('LAGOON_GIT_SAFE_BRANCH');

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
  catch (\Exception $e) {
    // phpcs:ignore DrupalPractice.CodeAnalysis.VariableAnalysis.UndefinedVariable
    $settings['container_yamls'][] = "$govcms_includes/redis-unavailable.services.yml";
    $settings['cache']['default'] = 'cache.backend.null';
  }
}

// ClamAV settings.
$clam_mode = getenv('CLAMAV_MODE') ?: 1;

if ($clam_mode == 0 || strtolower($clam_mode) == 'daemon') {
  $config['clamav.settings']['scan_mode'] = 0;
  $config['clamav.settings']['mode_daemon_tcpip']['hostname'] = getenv('CLAMAV_HOST') ?: 'localhost';
  $config['clamav.settings']['mode_daemon_tcpip']['port'] = getenv('CLAMAV_PORT') ?: 3310;
}
else {
  $config['clamav.settings']['scan_mode'] = 1;
  $config['clamav.settings']['mode_executable']['executable_path'] = '/usr/bin/clamscan';
}

// Non-deterministic hash salt.
$settings['hash_salt'] = hash('sha256', getenv('MARIADB_HOST'));
