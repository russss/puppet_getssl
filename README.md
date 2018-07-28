# getssl

#### Table of Contents

1. [Module description](#module-description)
1. [Setup - The basics of getting started with getssl](#setup)
    * [What getssl affects](#what-getssl-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with getssl](#beginning-with-getssl)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)
1. [Appendix](#appendix)

## Module description

This Module uses srvrco's getssl bash script to obtain SSL certificates.
The certificates can be used for various protocols like https, smtps, ldaps and so on.
For more information about the getssl script, [visit its site](https://github.com/srvrco/getssl)

You can use this module to just install getssl script and configure it by yourself, or
you can configure all relevant parameters and let this module obtain SSL certificates for you.

## Setup

### What getssl affects

This module creates folders and files under the base directory

* The base directory is `/opt/getssl/` unless overridden with the `base_dir` parameter
* For each domain it creates new sub directory `$base_dir/example.com/`

### Setup Requirements

If you want to use this module you have to install `curl`.
If you don't want to install curl manually you can install it with this module by setting the `manage_packages` parameter to true.

### Beginning with getssl

To install getssl you only have to include it in your manifest.

``` puppet
class { 'getssl': }
```

## Usage

### Configuring global configuration file

`getssl` is modular so you can set global configuration parameters
and the local per-domain parameters will overwrite the global ones.
To configure the global configuration parameters the following code is sufficient
for a minimal configuration.

``` puppet
class { 'getssl':
  account_mail    => 'foo@example.com',
  manage_packages => true,
}
```
### Configure domain specific parameters

To obtain a certificate for your domain use the domain class.
The following example is for Apache 2, but you can easily amend the configuration for your favourite webserver
e.g. nginx or lighttp.

``` puppet
  getssl::domain { 'example.com':
    acl                  => ['/usr/local/www/example.com/htdocs/.well-known/acme-challenge],
    sub_domains          => ['www.example.com', 'foo.example.com', 'bar.example.com'],
    domain_check_remote  => true,
    production           => true,
    domain_reload_command => 'systemctl restart apache2',
  }
```

This example tries to get a certificate for:
`example.com, www.example.com, foo.example.com, bar.example.com`

## Reference

### Public Classes

### Class: `getssl`

This class is used to install getssl on your server and configure the global parameters.

``` puppet
  class { 'getssl': }
```
**Description of parameters can be found in the appropriate .pp files**

### Public defined types

The defined type `getssl::domain` is used to configure domain-specific parameters. This type 
tries to obtain the certificates from letsencrypt.

**Description of parameters can be found in the appropriate .pp files**

## Limitations

This module has been tested on Debian 8 and 9 stable.
If you have tested it successfully with other versions or OS, please create an issue to discuss.
If changes were needed to support your OS, please submit a pull request.

> **Note**: There are some limitations to obtain SSL certificates by LetsEncrypt themselves.
Please also read the documentation of LetsEncrypt. 
[LetsEncrpyt Documentation](https://letsencrypt.org/docs/)

## Development

If you want to make improvements open a issue or make a pull request.
I will add few tests to this module but I am new to this so it will take time.

## Appendix

Big thanks to Daniel Thielking, the original author of this module, and to srvrco for his perfect bash written shell script. Thank you!
Thanks to the community of LetsEncrypt.
