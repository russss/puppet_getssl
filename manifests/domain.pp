# == Class: getssl:domain
#
#   This class configures the getssl domain part.
#   Use this class to configure your specific domains.
#
#   Additionally this class calls getssl script to obtain the domain certificates
#   and installs the appropriate cronjobs to ensure all certificates will be renewed
#   at the right time spot.
#
#
#   Parameters:
#   [*base_dir*]
#     Sets the base directory for getssl. Defaults to /opt/getssl
#   [*production*]
#     BOOL. If true: call production server of Letsencrypt.
#     If false: script calls staging server. Default false.
#   [*prod_ca*]
#     Production CA of Letsencrypt.
#   [*staging_ca*]
#     Staging CA fo Letsencrypt.
#   [*domain*]
#     - Used to create configuration folder and initial configuration
#     file for getssl. Defaults to undef. Must be set.
#   [*acl*]
#     Sets ACME Chalenge Location directory. Empty array by default
#   [*use_single_acl*]
#     Bool if true: only one acl directory must be specified.
#     If false: for each subdomain on acl. Default true.
#   [*domain_challenge_check_type*]
#     Protocol to use for the challenge (http or https). Defaults to http.
#   [*sub_domains*]
#     Array with all subdomains for specified certificate. Defaults to empty Array.
#   [*domain_private_key_alg*]
#     Sets Key Algorythm. Defaults to rsa
#   [*domain_account_key_length*]
#     Key length for ssl certificates. Defaults to 4096
#   [*domain_account_mail*]
#     Email for registration account. Defaults to undef
#   [*domain_check_remote*]
#     BOOL checks if certificate is available and online. Defaults to global configuration.
#   [*domain_check_remote_wait*]
#     Seconds to wait after executing reload_command before checking remote certificate.
#   [*domain_reload_command*]
#     Set command to reload e.g Webserver. Defaults to Global Command
#   [*domain_renew_allow*]
#     Integer sets interval of certificate renewal. Default 30 days before expiration.
#   [*domain_server_type*]
#     Sets servertype to check e.g HTTPs. Default https
#   [*ca_cert_location*]
#     Configures location for Certificate Authority File. Defaults to undef
#   [*domain_cert_location*]
#     Configures certifacte location. Defaults to undef.
#   [*domain_chain_location*]
#     Configures chain file location. Defaults to undef.
#   [*domain_key_cert_location*]
#     Configures Key-Cert file location. Defaults to undef.
#   [*domain_key_location*]
#     Configures Key file location. Defaults to undef.
#   [*domain_pem_location*]
#     Configures Pem file location. Defaults to undef.
#   [*suppress_getssl_run*]
#     If true, does not run getssl as part of the puppet run, but relies on the cron job.
#
#  Sample Usage:
#    getssl::domain { 'example.org':
#      production  => true,
#      acl         => ['/var/www/default/.well-known']
#      sub_domains => ['www.example.org', 'foo.example.org', 'bar.example.org']
#    }
#
define getssl::domain (
  String            $base_dir                  = $getssl::base_dir,
  Boolean           $production                = $getssl::params::production,
  String            $prod_ca                   = $getssl::params::prod_ca,
  String            $staging_ca                = $getssl::params::staging_ca,
  String            $domain                    = $name,
  Array[String]     $acl                       = $getssl::params::acl,
  Boolean           $use_single_acl            = $getssl::params::use_single_acl,
  Optional[String]  $domain_challenge_check_type = $getssl::params::domain_challenge_check_type,
  Array[String]     $sub_domains               = $getssl::params::sub_domains,
  String            $domain_private_key_alg    = $getssl::params::domain_private_key_alg,
  Integer           $domain_account_key_length = $getssl::params::domain_account_key_length,
  Optional[String]  $domain_account_mail       = $getssl::params::domain_account_mail,
  Boolean           $domain_check_remote       = $getssl::params::domain_check_remote,
  Optional[Integer] $domain_check_remote_wait  = $getssl::params::domain_check_remote_wait,
  Optional[String]  $domain_reload_command     = $getssl::params::domain_reload_command,
  Integer           $domain_renew_allow        = $getssl::params::domain_renew_allow,
  String            $domain_server_type        = $getssl::params::domain_server_type,
  Optional[String]  $ca_cert_location          = $getssl::params::ca_cert_location,
  Optional[String]  $domain_cert_location      = $getssl::params::domain_cert_location,
  Optional[String]  $domain_chain_location     = $getssl::params::domain_chain_location,
  Optional[String]  $domain_key_cert_location  = $getssl::params::domain_key_cert_location,
  Optional[String]  $domain_key_location       = $getssl::params::domain_key_location,
  Optional[String]  $domain_pem_location       = $getssl::params::domain_pem_location,
  Boolean           $suppress_getssl_run       = $getssl::params::suppress_getssl_run,
) {
  # Use production api of letsencrypt only if $production is true
  if $production {
    $ca = $prod_ca
  } else {
    $ca = $staging_ca
  }

  $parent_dir = {
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }

  ensure_resource('file', "${base_dir}/conf/${domain}", $parent_dir)

  if $suppress_getssl_run {
    # Don't run getssl immediately
    $config_notifiers = []
  } else {
    # Default behaviour
    $config_notifiers = [Exec["${base_dir}/getssl -U -w ${base_dir}/conf -q ${domain}"]]
  }

  file { "${base_dir}/conf/${domain}/getssl.cfg":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => epp('getssl/domain_getssl.cfg.epp', {
        'acl'                         => $acl,
        'base_dir'                    => $base_dir,
        'ca'                          => $ca,
        'ca_cert_location'            => $ca_cert_location,
        'domain'                      => $domain,
        'domain_account_key_length'   => $domain_account_key_length,
        'domain_account_mail'         => $domain_account_mail,
        'domain_cert_location'        => $domain_cert_location,
        'domain_chain_location'       => $domain_chain_location,
        'domain_check_remote'         => $domain_check_remote,
        'domain_check_remote_wait'    => $domain_check_remote_wait,
        'domain_key_cert_location'    => $domain_key_cert_location,
        'domain_key_location'         => $domain_key_location,
        'domain_pem_location'         => $domain_pem_location,
        'domain_private_key_alg'      => $domain_private_key_alg,
        'domain_reload_command'       => $domain_reload_command,
        'domain_renew_allow'          => $domain_renew_allow,
        'domain_server_type'          => $domain_server_type,
        'sub_domains'                 => $sub_domains,
        'use_single_acl'              => $use_single_acl,
        'domain_challenge_check_type' => $domain_challenge_check_type
    }),
    notify  => $config_notifiers,
  }

  unless $suppress_getssl_run {
    exec { "${base_dir}/getssl -U -w ${base_dir}/conf -q ${domain}":
      path        => ['/bin', '/usr/bin', '/usr/sbin', $base_dir],
      refreshonly => true,
    }
  }
}
