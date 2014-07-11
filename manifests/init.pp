# == Class: awstools
# This module contains script and utilities to work with AWS
#
class awstools (
  $cert_path      = $::awstools_cert_path,
  $privkey_path   = $::awstools_privkey_path,
) {

  if ($cert_path == '') or ($privkey_path == '') {
    fail('specify cert_path and privkey_path or define global variables $::awstools_cert_path and $::awstools_privkey_path')
  }

  if !defined(Package['ec2-api-tools']) {
    package{'ec2-api-tools':
      ensure => present
    }
  }

  file {'/root/.ec2':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => 755,
    require => Package['ec2-api-tools']
  }

  $cert_filename = inline_template("<%= cert_path.split('/').at(-1) %>")
  $pkey_filename = inline_template("<%= privkey_path.split('/').at(-1) %>")

  file {"/root/.ec2/${cert_filename}":
    source  => $cert_path,
    mode    => '0644',
    require => File['/root/.ec2']
  }

  file {"/root/.ec2/${pkey_filename}":
    source  => $privkey_path,
    mode    => '0644',
    require => File['/root/.ec2']
  }

}
