<?php

/**
 * @file
 * Drupal 9 all environment configuration file.
 *
 * This file should contain all settings.php configurations that are needed by
 * all environments.
 */

// phpcs:disable Drupal.Classes.ClassFileName.NoMatch,Drupal.Commenting.ClassComment.Short

// This variable may be set from settings.php. Fallback to current directory.
// @see https://github.com/govCMS/govcms8-scaffold-paas/blob/57cddd8/web/sites/default/settings.php#L48
// phpcs:ignore DrupalPractice.CodeAnalysis.VariableAnalysis.UndefinedVariable
$govcms_includes = $govcms_includes ?? __DIR__;

/**
 * Include the corresponding *.services.yml.
 */
// phpcs:ignore DrupalPractice.CodeAnalysis.VariableAnalysis.UndefinedVariable
$settings['container_yamls'][] = $govcms_includes . '/all.services.yml';

// Configuration sync directory.
$settings['config_sync_directory'] = '../config/default';

// @see https://govdex.gov.au/jira/browse/GOVCMS-993
// @see https://github.com/drupal/drupal/blob/7.x/sites/default/default.settings.php#L518
// @see https://api.drupal.org/api/drupal/includes%21bootstrap.inc/function/drupal_fast_404/8.x
$contrib_path = 'modules/contrib';
if (file_exists($contrib_path . '/fast404/fast404.inc')) {
  include_once $contrib_path . 'fast404/fast404.inc';
}
// @todo this should be in the if block above?
$settings['fast404_exts'] = getenv('GOVCMS_FAST404_EXTS') ?: '/^(?!robots)^(?!\/system\/files).*\.(?:png|gif|jpe?g|svg|tiff|bmp|raw|webp|pdf?|docx?|xlsx?|pptx?|swf|flv|cgi|dll|exe|nsf|cfm|ttf|bat|pl|asp|ics|rtf)$/i';
$settings['fast404_html'] = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><title>404 Not Found</title></head><body><h1>Not Found</h1><p>The requested URL "@path" was not found on this server.</p></body></html>';
$settings['fast404_whitelist'] = ['robots.txt', 'system/files'];

// Public, private and temporary files paths.
$settings['file_public_path'] = 'sites/default/files';
$settings['file_private_path'] = 'sites/default/files/private';
$settings['file_temp_path'] = 'sites/default/files/private/tmp';

// ClamAV settings.
$clam_mode = getenv('CLAMAV_MODE') ?: 1;

if ($clam_mode == 0 || strtolower($clam_mode) == 'daemon') {
  $config['clamav.settings']['scan_mode'] = 0;
  $config['clamav.settings']['mode_daemon_tcpip']['hostname'] = getenv('CLAMAV_HOST') ?: 'av';
  $config['clamav.settings']['mode_daemon_tcpip']['port'] = getenv('CLAMAV_PORT') ?: 3310;
}

// Non-deterministic hash salt.
$settings['hash_salt'] = hash('sha256', getenv('MARIADB_HOST'));


// Allow custom themes to provide custom 404 pages.
// By placing a file called 404.html in the root of their theme repository.
// 404 pages must be less than 512KB to be used. This is a performance
// measure to ensure transfer, memory usage and disk reads are manageable.
// @todo include a class file, not inline like this.
if (!class_exists('GovCms404Page')) {
  /**
   * Class GovCms404Page.
   */
  class GovCms404Page {

    const MAX_FILESIZE = 5132288;

    /**
     * The filepath of the file with contents of 404 page.
     *
     * @var string
     */
    protected $filepath;

    /**
     * The default contents of 404 page.
     *
     * @var string
     */
    protected $default;

    /**
     * GovCms404Page constructor.
     *
     * @param string $fast_404_html
     *   Default HTML contents of 404 page.
     */
    public function __construct($fast_404_html) {
      $this->filepath = '/app/404.html';
      $this->default = $fast_404_html;
    }

    /**
     * Magic method to cast class object value to string.
     */
    public function __toString() {
      // filesize() will check the file exists. So as long as
      // we suppress the output, it won't be an issue to not
      // check for the presence of a file first.
      $filesize = @filesize($this->filepath);
      if ($filesize === FALSE || $filesize > self::MAX_FILESIZE) {
        return $this->default;
      }

      return file_get_contents($this->filepath);
    }

  }
}

$settings['fast404_html'] = new GovCms404Page($settings['fast404_html']);

// Ensure redirects created with the redirect module are able to set appropriate
// caching headers to ensure that Varnish and Akamai can cache the HTTP 301.
// @todo move to lagoon.settings.php
$settings['page_cache_invoke_hooks'] = TRUE;
$settings['redirect_page_cache'] = TRUE;

// Ensure that administrators do not block drush access through the UI.
$config['shield.settings']['allow_cli'] = TRUE;

// Allow projects to increase the HTTP client timeout for CLI requests.
// This will impact migrations that rely on external services and other
// HTTP requests that the Drupal request library makes.
//
// This has only been added to affect CLI because this timeout can hold
// PHP processes if a remote request is unavailable, as sites can do
// inline HTTP requests this is a performance risk.
if (defined('STDIN') || in_array(PHP_SAPI, ['cli', 'cli-server'])) {
  if (is_numeric($http_client_timeout = getenv('GOVCMS_HTTP_CLIENT_TIMEOUT'))) {
    $settings['http_client_config']['timeout'] = $http_client_timeout;
  }
}

// Allow projects to increase PHP memory limit for CLI requests.
if (in_array(PHP_SAPI, ['cli', 'cli-server'])) {
  if ($limit = getenv('GOVCMS_CLI_MEMORY_LIMIT')) {
    ini_set('memory_limit', $limit);
  }
}

// Prevents legacy Symfony ApcClassLoader from being used instead of Composer's.
$settings['class_loader_auto_detect'] = FALSE;

$config['search_api.server.lagoon_solr']['backend_config']['connector_config']['path'] = '/';
$config['search_api.server.lagoon_solr']['backend_config']['connector_config']['core'] = 'drupal';

// Configure seckit to emit the HSTS headers when a user is likely visiting
// govCMS using a domain with valid SSL.
//
// This includes:
// - "*-site.test.govcms.gov.au" domains (TEST)
// - "*-site.govcms.gov.au" domains (PROD)
// - "*.gov.au" domains (PROD)
// - "*.org.au" domains (PROD)
//
// When the domain likely does not have valid SSL, then HSTS is disabled
// explicitly (to prevent the database values being used).
//
// @see https://govdex.gov.au/jira/browse/GOVCMS-1109
// @see http://cgit.drupalcode.org/seckit/tree/includes/seckit.form.inc#n397
//
if (preg_match("~^.+(\.gov\.au|\.org\.au)$~i", $_SERVER['HTTP_HOST'])) {
  $config['seckit.settings']['seckit_ssl']['hsts'] = TRUE;
  $config['seckit.settings']['seckit_ssl']['hsts_max_age'] = 31536000;
  $config['seckit.settings']['seckit_ssl']['hsts_subdomains'] = FALSE;
}
else {
  $config['seckit.settings']['seckit_ssl']['hsts'] = FALSE;
  $config['seckit.settings']['seckit_ssl']['hsts_max_age'] = 0;
  $config['seckit.settings']['seckit_ssl']['hsts_subdomains'] = FALSE;
}

// Trusted host patterns are not necessary on lagoon as traffic will only
// be routed to your site via the routes (hosts) defined in .lagoon.yml.
if (getenv('LAGOON')) {
  $settings['trusted_host_patterns'][] = '.*';
}
