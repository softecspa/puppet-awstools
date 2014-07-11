# == Class: awstools::ip
# This class require awstools and push aws-cache-ip-list script
#
class awstools::ip {

  require awstools

  file { '/usr/local/sbin/aws-cache-ip-list.sh':
    source  => 'puppet:///modules/awstools/sbin/aws-cache-ip-list.sh',
    mode    => '0755';
  }

  cron::customentry { 'aws-cache-ip-list':
    minute => '*/2',
    command => '/usr/local/sbin/aws-cache-ip-list.sh',
  }
}
