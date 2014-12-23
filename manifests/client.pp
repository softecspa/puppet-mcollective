# == class mcollective::client
#
#  Install Mcollective Client, used on workstations
#
# === Params
#
# === Examples
#
class mcollective::client(
  $ensure=present,
  $stomp_host,
  $stomp_vhost,
  $stomp_user,
  $stomp_pass,
  $stomp_port=61613,
  $ssl_middleware=false,
  $ssl_plugin=false,
)
{
  if ! defined(Class['mcollective::common']) {
    class {'mcollective::common':
      ensure => $ensure
    }
  }

  package { 'mcollective-client':
    ensure  => present,
    require => Class['mcollective::common'];
  }

  file { 'mcollective-client.cfg':
    path    => '/etc/mcollective/client.cfg',
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => template('mcollective/client.cfg.erb'),
    require => Package['mcollective-client'],
  }

  file{ '/etc/mcollective/client_certs':
    ensure   => directory,
    owner    => root,
    group    => root,
    mode     => '0755',
    require  => Package['mcollective-client'],
  }
}
