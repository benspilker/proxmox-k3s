<?php
$CONFIG = array (
  'htaccess.RewriteBase' => '/',
  'memcache.local' => '\\OC\\Memcache\\APCu',
  'apps_paths' => 
  array (
    0 => 
    array (
      'path' => '/var/www/html/apps',
      'url' => '/apps',
      'writable' => false,
    ),
    1 => 
    array (
      'path' => '/var/www/html/custom_apps',
      'url' => '/custom_apps',
      'writable' => true,
    ),
  ),
  'upgrade.disable-web' => true,
  'passwordsalt' => 'lLXFzNPNo9zfTTHEIhyvje7bNy3Bv9',
  'secret' => 'UKnMXKg4IweuycR6aUFChCD7LZaSvcJrkagHDJg0oG4OmmAv',
  'trusted_domains' => 
  array (
    0 => 'localhost',
    1 => 'nextcloud.kube.home',
    2 => 'nextcloud.ne-inc.com',
  ),
  'datadirectory' => '/var/www/html/data',
  'dbtype' => 'sqlite3',
  'version' => '30.0.5.1',
  'overwrite.cli.url' => 'https://nextcloud.ne-inc.com',
  'overwriteprotocol' =>'https',
  'dbname' => 'nextcloud',
  'installed' => true,
  'instanceid' => 'ocjx576zgn0x',
);