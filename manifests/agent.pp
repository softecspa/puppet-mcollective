class mcollective::agent(
  $ensure=present,
  $stomp_host,
  $stomp_vhost,
  $stomp_user,
  $stomp_pass,
  $stomp_port=61613
)
{
  if ! defined(Class['mcollective::common']) {
    class {'mcollective::common':
      ensure => $ensure
    }
  }

  apt::pin {
  'mcollective-client':
      version => $mcollective::mcollective_version,
      require => Class['mcollective::common'];
  } ->
  package {
    'mcollective-client': ensure => $mcollective::mcollective_version;
  }

  file { "mcollective-client.cfg":
    path  => "/etc/mcollective/client.cfg",
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => template('mcollective/client.cfg.erb'),
    require => Package['mcollective-client'],
  }

  file{
    "/etc/mcollective/client_certs":
      ensure   => directory,
      owner    => root,
      group    => root,
      mode     => 755,
      require  => Package['mcollective-client'],
  }
}
