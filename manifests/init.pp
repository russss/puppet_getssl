# Class: getssl
# ===========================
#
# This is the default init.pp class. This Class installs getssl
# and ensures that sufficient directories and files are createt.
#
# Adds a cronjob to ensure all your certificates are updated properly
#
# Parameters
#   [*base_dir*]
#     Base directory for getssl script and configuration. Default /opt
#   [*production*]
#     Bool if true: use production letsencrypt server.
#     If false use staging server. Default false
#   [*prod_ca*]
#     Production CA of Letsencrypt.
#   [*staging_ca*]
#     Staging CA fo Letsencrypt.
#   [*manage_packages*]
#     Bool if true: Install specified Packages. If false don't. Default false
#   [*packages*]
#     Installs sufficient Packages for getssl. Default curl
#   [*manage_cron*]
#     Whether to manage a cronjob for maintaining certificates.  Defaults to true.
#   [*account_mail*]
#     Global Email Address for Letsencrypt registration
#   [*account_key_length*]
#     Account key length. Default 4096
#   [*private_key_alg*]
#     Account key algorythm. Default rsa
#   [*reload_command*]
#     Specifies reload for services. E.g systemctl restart apach2. Default undef
#   [*reuse_private_key*]
#     Bool if true private key is generated only once and used for each domain. Default true
#   [*renew_allow*]
#     Integer sets interval of certificate renewal. Default 30 days before expiration.
#   [*server_type*]
#     Sets server type e.g to https. Default https
#   [*check_remote*]
#     Bool. Check if certificate is correct installed. Default true
#   [*ssl_conf*]
#     Default location for openssl.cnf file. Default /usr/lib/ssl/openssl.cnf
#
# Action
# ===========================
#
#   - Installs getssl
#   - Configure global getssl.cfg
#   - Installs cronjob for certificate renewal
#
# Examples
# --------
#
#   class { 'getssl':
#     account_mail => 'admin@example.com',
#   }
#
# Authors
# -------
#
# Author Name <github@thielking-vonessen.de>
class getssl (
  String            $base_dir            = $getssl::params::base_dir,
  Bool              $production         = $getssl::params::production,
  String            $prod_ca            = $getssl::params::prod_ca,
  String            $staging_ca         = $getssl::params::staging_ca,
  Bool              $manage_packages    = $getssl::params::manage_packages,
  Array[String]     $packages           = $getssl::params::packages,
  Bool              $manage_cron        = $getssl::params::manage_cron,
  Optional[String]  $account_mail       = $getssl::params::account_mail,
  Integer           $account_key_length = $getssl::params::account_key_length,
  String            $private_key_alg    = $getssl::params::private_key_alg,
  String            $reload_command     = $getssl::params::reload_command,
  Bool              $reuse_private_key  = $getssl::params::reuse_private_key,
  Integer           $renew_allow        = $getssl::params::renew_allow,
  String            $server_type        = $getssl::params::server_type,
  Bool              $check_remote       = $getssl::params::check_remote,
  String            $ssl_conf           = $getssl::params::ssl_conf,
) inherits getssl::params {
  # Use production api of letsencrypt if $production is true
  if $production {
    $ca = $prod_ca
  } else {
    $ca = $staging_ca
  }

  # Install packages if $manage_packages is true
  if $manage_packages {
    package { $packages:
      ensure => latest,
    }
  }

  # Create Base Directories
  file { $base_dir:
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }
  file { "${base_dir}/conf":
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }
  file { "${base_dir}/getssl":
    ensure => file,
    force  => true,
    owner  => root,
    group  => root,
    mode   => '0700',
    source => 'puppet:///modules/getssl/getssl.sh',
  }

  file { "${base_dir}/conf/getssl.cfg":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => epp('getssl/global_getssl.cfg.epp', {
        'ca'                 => $ca,
        'account_mail'       => $account_mail,
        'account_key_length' => $account_key_length,
        'base_dir'           => $base_dir,
        'private_key_alg'    => $private_key_alg,
        'reuse_private_key'  => $reuse_private_key,
        'reload_command'     => $reload_command,
        'renew_allow'        => $renew_allow,
        'server_type'        => $server_type,
        'check_remote'       => $check_remote,
        'ssl_conf'           => $ssl_conf,
    }),
  }

  if $manage_cron {
    cron { 'getssl_renew':
      ensure  => present,
      command => "${base_dir}/getssl -w ${base_dir}/conf -a -q -U",
      user    => 'root',
      hour    => '23',
      minute  => '5',
    }
  }
}
